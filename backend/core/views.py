from rest_framework import viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from django.contrib.auth.models import User
from rest_framework_simplejwt.tokens import RefreshToken

from .models import (
    Patient,
    Doctor,
    HealthProfile,
    Appointment,
    Query,
    Symptom,
    Question,
    AnswerChoice,
    TriageResult
)

from .serializers import (
    PatientSerializer,
    HealthProfileSerializer,
    AppointmentSerializer,
    QuerySerializer,
    SymptomSerializer,
    QuestionSerializer
)

# ==================================
# ROLE HELPER
# ==================================

def get_user_role(user):
    if user.is_staff:
        return "admin"
    elif Doctor.objects.filter(user=user).exists():
        return "doctor"
    else:
        return "patient"

# ==================================
# REGISTER
# ==================================

@api_view(["POST"])
def register_patient(request):
    name = request.data.get("name")
    age = request.data.get("age")
    email = request.data.get("email")
    phone = request.data.get("phone")
    password = request.data.get("password")
    accessibility_type = request.data.get("accessibility_type", "None")

    if User.objects.filter(username=email).exists():
        return Response({"error": "User already exists"}, status=400)

    user = User.objects.create_user(
        username=email,
        email=email,
        password=password
    )

    Patient.objects.create(
        user=user,
        name=name,
        age=age,
        email=email,
        phone=phone,
        accessibility_type=accessibility_type
    )

    return Response({"message": "Patient registered successfully"})

# ==================================
# LOGIN (JWT + Accessibility)
# ==================================

@api_view(["POST"])
def custom_login(request):
    username = request.data.get("username")
    password = request.data.get("password")

    user = User.objects.filter(username=username).first()

    if not user:
        return Response({"error": "User not found"}, status=404)

    if not user.check_password(password):
        return Response({"error": "Invalid password"}, status=400)

    refresh = RefreshToken.for_user(user)
    role = get_user_role(user)

    accessibility_type = "None"

    if role == "patient":
        patient = Patient.objects.filter(user=user).first()
        if patient:
            accessibility_type = patient.accessibility_type

    return Response({
        "access": str(refresh.access_token),
        "role": role,
        "accessibility_type": accessibility_type
    })

# ==================================
# HOSPITAL LOGIN
# ==================================

@api_view(["POST"])
def hospital_login(request):

    username = request.data.get("username")
    password = request.data.get("password")

    user = User.objects.filter(username=username).first()

    if not user:
        return Response({"error": "User not found"}, status=404)

    if not user.check_password(password):
        return Response({"error": "Invalid password"}, status=400)

    if user.is_staff:
        role = "admin"
    elif Doctor.objects.filter(user=user).exists():
        role = "doctor"
    else:
        return Response({"error": "Unauthorized"}, status=403)

    return Response({"role": role})

# ==================================
# HOSPITAL USERS
# ==================================

@api_view(["GET"])
def hospital_users(request):

    users = []

    admins = User.objects.filter(is_staff=True)
    for admin in admins:
        users.append({
            "username": admin.username,
            "role": "admin",
            "name": admin.username
        })

    doctors = Doctor.objects.all()
    for doctor in doctors:
        users.append({
            "username": doctor.user.username,
            "role": "doctor",
            "name": doctor.name
        })

    return Response(users)

# ==================================
# VIEWSETS
# ==================================

class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer
    permission_classes = [IsAuthenticated]


class HealthProfileViewSet(viewsets.ModelViewSet):
    queryset = HealthProfile.objects.all()
    serializer_class = HealthProfileSerializer
    permission_classes = [IsAuthenticated]


class AppointmentViewSet(viewsets.ModelViewSet):
    serializer_class = AppointmentSerializer
    permission_classes = [IsAuthenticated]

    # 🔥 FILTER APPOINTMENTS BY LOGGED-IN USER
    def get_queryset(self):
        patient = Patient.objects.filter(user=self.request.user).first()
        if patient:
            return Appointment.objects.filter(patient=patient)
        return Appointment.objects.none()

    def perform_create(self, serializer):
        patient = Patient.objects.get(user=self.request.user)
        serializer.save(patient=patient)

class QueryViewSet(viewsets.ModelViewSet):
    queryset = Query.objects.all()
    serializer_class = QuerySerializer
    permission_classes = [IsAuthenticated]

# ==================================
# TRIAGE
# ==================================

@api_view(["GET"])
def get_symptoms(request):
    symptoms = Symptom.objects.all()
    serializer = SymptomSerializer(symptoms, many=True)
    return Response(serializer.data)


@api_view(["GET"])
def get_questions(request, symptom_id):
    questions = Question.objects.filter(symptom_id=symptom_id)
    serializer = QuestionSerializer(questions, many=True)
    return Response(serializer.data)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def evaluate_triage(request):

    patient = Patient.objects.get(user=request.user)
    symptom_id = request.data.get("symptom_id")
    selected_answers = request.data.get("answers", [])

    total_score = 0

    for answer_id in selected_answers:
        choice = AnswerChoice.objects.filter(id=answer_id).first()
        if choice:
            total_score += choice.score

    if total_score <= 3:
        risk = "Low"
        specialist = "General Physician"
    elif total_score <= 6:
        risk = "Moderate"
        specialist = "Internal Medicine"
    elif total_score <= 9:
        risk = "High"
        specialist = "Specialist Consultation"
    else:
        risk = "Emergency"
        specialist = "Emergency Department"

    TriageResult.objects.create(
        patient=patient,
        symptom_id=symptom_id,
        total_score=total_score,
        risk_level=risk,
        recommended_specialist=specialist
    )

    return Response({
        "risk_level": risk,
        "recommended_specialist": specialist,
        "total_score": total_score
    })

# ==================================
# HISTORY
# ==================================

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def patient_history(request):

    patient = Patient.objects.get(user=request.user)
    results = TriageResult.objects.filter(patient=patient).order_by("-created_at")

    data = []

    for result in results:
        data.append({
            "symptom": result.symptom.name,
            "risk_level": result.risk_level,
            "recommended_specialist": result.recommended_specialist,
            "total_score": result.total_score,
            "created_at": result.created_at
        })

    return Response(data)

# ==================================
# DOCTORS
# ==================================

@api_view(["GET"])
def get_doctors(request):
    doctors = Doctor.objects.all()

    data = [
        {
            "id": doctor.id,
            "name": doctor.name,
            "username": doctor.user.username,
            "specialization": doctor.specialization,
        }
        for doctor in doctors
    ]

    return Response(data)

# ==================================
# DASHBOARDS
# ==================================

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def doctor_dashboard(request):

    doctor = Doctor.objects.filter(user=request.user).first()

    if not doctor:
        return Response({"error": "Doctor not found"}, status=404)

    appointments = Appointment.objects.filter(doctor=doctor)

    data = []

    for appt in appointments:

        # 🔥 Get latest triage result of patient
        triage = TriageResult.objects.filter(
            patient=appt.patient
        ).order_by("-created_at").first()

        triage_data = None

        if triage:
            triage_data = {
                "symptom": triage.symptom.name if triage.symptom else None,
                "total_score": triage.total_score,
                "risk_level": triage.risk_level,
                "recommended_specialist": triage.recommended_specialist,
                "created_at": triage.created_at
            }

        data.append({
            "id": appt.id,
            "patient_name": appt.patient.name,
            "doctor_name": doctor.name,
            "appointment_date": appt.appointment_date,
            "status": appt.status,
            "triage": triage_data   # ✅ NEW FIELD
        })

    return Response(data)
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def admin_dashboard(request):

    if not request.user.is_staff:
        return Response({"error": "Unauthorized"}, status=403)

    appointments = Appointment.objects.all()

    data = []

    for appt in appointments:
        data.append({
            "patient_name": appt.patient.name,
            "doctor_name": appt.doctor.name,
            "appointment_date": appt.appointment_date,
            "status": appt.status
        })

    return Response(data)

# ==================================
# CANCEL APPOINTMENT
# ==================================

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def cancel_appointment(request, pk):

    patient = Patient.objects.get(user=request.user)
    appointment = Appointment.objects.filter(id=pk, patient=patient).first()

    if not appointment:
        return Response({"error": "Appointment not found"}, status=404)

    appointment.status = "Cancelled"
    appointment.save()

    return Response({"message": "Appointment cancelled"})

# ==================================
# DOCTOR MESSAGE
# ==================================

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def send_doctor_message(request):

    doctor = Doctor.objects.filter(user=request.user).first()

    if not doctor:
        return Response({"error": "Only doctors can send messages"}, status=403)

    patient_id = request.data.get("patient_id")
    message = request.data.get("message")

    if not patient_id or not message:
        return Response({"error": "patient_id and message required"}, status=400)

    patient = Patient.objects.filter(id=patient_id).first()

    if not patient:
        return Response({"error": "Patient not found"}, status=404)

    Query.objects.create(
        patient=patient,
        title="Doctor Message",
        category="Doctor",
        description=message,
        status="Answered"
    )

    return Response({"message": "Message sent successfully"})

from rest_framework import serializers
from .models import (
    Patient,
    HealthProfile,
    Appointment,
    Query,
    Symptom,
    Question,
    AnswerChoice,
    TriageResult,
    DoctorMessage
)

# ===============================
# EXISTING SERIALIZERS (UPDATED SAFELY)
# ===============================

class PatientSerializer(serializers.ModelSerializer):
    # 🆕 Make accessibility_type optional (Safe for old users)
    accessibility_type = serializers.CharField(required=False)

    class Meta:
        model = Patient
        fields = '__all__'


class HealthProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthProfile
        fields = '__all__'


# ===============================
# 🆕 DOCTOR MESSAGE SERIALIZER
# ===============================

class DoctorMessageSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source="doctor.name", read_only=True)
    patient_name = serializers.CharField(source="patient.name", read_only=True)

    class Meta:
        model = DoctorMessage
        fields = [
            "id",
            "doctor",
            "doctor_name",
            "patient",
            "patient_name",
            "appointment",
            "message",
            "created_at"
        ]
        read_only_fields = ["doctor", "created_at"]


# ===============================
# APPOINTMENT SERIALIZER (UNCHANGED)
# ===============================

class AppointmentSerializer(serializers.ModelSerializer):
    doctor_name = serializers.CharField(source="doctor.name", read_only=True)
    messages = DoctorMessageSerializer(
        many=True,
        source="doctormessage_set",
        read_only=True
    )

    class Meta:
        model = Appointment
        fields = [
            'id',
            'doctor',
            'doctor_name',
            'appointment_date',
            'status',
            'messages'
        ]
        read_only_fields = ['patient']


# ===============================
# QUERY SERIALIZER
# ===============================

class QuerySerializer(serializers.ModelSerializer):
    class Meta:
        model = Query
        fields = '__all__'


# ===============================
# TRIAGE SERIALIZERS
# ===============================

class AnswerChoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnswerChoice
        fields = ["id", "text", "score"]


class QuestionSerializer(serializers.ModelSerializer):
    choices = AnswerChoiceSerializer(many=True, read_only=True)

    class Meta:
        model = Question
        fields = ["id", "text", "choices"]


class SymptomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Symptom
        fields = ["id", "name"]


class TriageResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = TriageResult
        fields = '__all__'

# ==================================
# GET LOGGED-IN PATIENT PROFILE
# ==================================

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def my_profile(request):

    patient = Patient.objects.filter(user=request.user).first()

    if not patient:
        return Response({"error": "Patient not found"}, status=404)

    serializer = PatientSerializer(patient)
    return Response(serializer.data)

# ==================================
# DOCTOR APPROVE APPOINTMENT
# ==================================

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def approve_appointment(request, pk):

    doctor = Doctor.objects.filter(user=request.user).first()

    if not doctor:
        return Response({"error": "Only doctors can approve"}, status=403)

    appointment = Appointment.objects.filter(id=pk, doctor=doctor).first()

    if not appointment:
        return Response({"error": "Appointment not found"}, status=404)

    appointment.status = "Approved"
    appointment.save()

    return Response({"message": "Appointment approved"})


# ==================================
# DOCTOR REJECT APPOINTMENT
# ==================================

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def reject_appointment(request, pk):

    doctor = Doctor.objects.filter(user=request.user).first()

    if not doctor:
        return Response({"error": "Only doctors can reject"}, status=403)

    appointment = Appointment.objects.filter(id=pk, doctor=doctor).first()

    if not appointment:
        return Response({"error": "Appointment not found"}, status=404)

    appointment.status = "Rejected"
    appointment.save()

    return Response({"message": "Appointment rejected"})


# ==================================
# DOCTOR SEND MESSAGE TO APPOINTMENT
# ==================================

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def send_message_to_appointment(request, pk):

    doctor = Doctor.objects.filter(user=request.user).first()

    if not doctor:
        return Response({"error": "Only doctors allowed"}, status=403)

    appointment = Appointment.objects.filter(id=pk, doctor=doctor).first()

    if not appointment:
        return Response({"error": "Appointment not found"}, status=404)

    message_text = request.data.get("message")

    if not message_text:
        return Response({"error": "Message required"}, status=400)

    from .models import DoctorMessage

    DoctorMessage.objects.create(
        doctor=doctor,
        patient=appointment.patient,
        appointment=appointment,
        message=message_text
    )

    return Response({"message": "Message sent successfully"})