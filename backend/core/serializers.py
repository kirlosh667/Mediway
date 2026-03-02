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