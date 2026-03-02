from rest_framework import viewsets
from .models import Patient, HealthProfile, Appointment
from .serializers import PatientSerializer, HealthProfileSerializer, AppointmentSerializer


class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer


class HealthProfileViewSet(viewsets.ModelViewSet):
    queryset = HealthProfile.objects.all()
    serializer_class = HealthProfileSerializer

    def perform_create(self, serializer):
        severity = self.request.data.get('severity')
        duration = self.request.data.get('duration')

        triage_level = "Low"

        if severity == "Emergency":
            triage_level = "Emergency"
        elif severity == "High":
            triage_level = "Urgent"
        elif severity == "Moderate" and "7" in duration:
            triage_level = "Priority"

        instance = serializer.save()

        print(f"Triage Level: {triage_level}")


class AppointmentViewSet(viewsets.ModelViewSet):
    queryset = Appointment.objects.all()
    serializer_class = AppointmentSerializer