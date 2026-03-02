from django.contrib.auth.models import User
from django.db import models


# =========================
# EXISTING MODELS (UNCHANGED + ACCESSIBILITY ADDED SAFELY)
# =========================


class Patient(models.Model):
    # 🆕 Accessibility Choices (NEW - SAFE ADDITION)
    ACCESSIBILITY_CHOICES = [
        ('None', 'None'),
        ('Blind', 'Blind / Low Vision'),
        ('Deaf', 'Deaf / Hard of Hearing'),
        ('Speech', 'Speech Impaired'),
        ('Motor', 'Motor Disability'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True)

    name = models.CharField(max_length=100)
    age = models.IntegerField()
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=15)

    # 🆕 NEW FIELD (Optional + Default Safe)
    accessibility_type = models.CharField(
        max_length=20,
        choices=ACCESSIBILITY_CHOICES,
        default='None',
        blank=True
    )

    def __str__(self):
        return self.name


class Doctor(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    specialization = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class HealthProfile(models.Model):
    SEVERITY_CHOICES = [
        ('Low', 'Low'),
        ('Moderate', 'Moderate'),
        ('High', 'High'),
        ('Emergency', 'Emergency'),
    ]

    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    symptom_category = models.CharField(max_length=100)
    duration = models.CharField(max_length=50)
    severity = models.CharField(max_length=20, choices=SEVERITY_CHOICES)
    notes = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.patient.name} - {self.symptom_category}"


class Appointment(models.Model):

    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Approved', 'Approved'),
        ('Rejected', 'Rejected'),
        ('Completed', 'Completed'),
        ('Cancelled', 'Cancelled'),
    ]

    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE)
    appointment_date = models.DateTimeField()
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='Pending'
    )

    def __str__(self):
        return f"{self.patient.name} - {self.doctor.name}"

class Query(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    category = models.CharField(max_length=100)
    description = models.TextField()
    status = models.CharField(max_length=20, default="Pending")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title


# =========================
# NEW QUESTION-BASED TRIAGE MODELS
# =========================

class Symptom(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class Question(models.Model):
    symptom = models.ForeignKey(
        Symptom,
        on_delete=models.CASCADE,
        related_name="questions"
    )
    text = models.TextField()

    def __str__(self):
        return f"{self.symptom.name} - {self.text}"


class AnswerChoice(models.Model):
    question = models.ForeignKey(
        Question,
        on_delete=models.CASCADE,
        related_name="choices"
    )
    text = models.CharField(max_length=200)
    score = models.IntegerField()  # Used for triage scoring

    def __str__(self):
        return f"{self.question.text} - {self.text}"


# =========================
# OPTIONAL (ADVANCED) - STORE TRIAGE RESULT
# =========================

class TriageResult(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    symptom = models.ForeignKey(Symptom, on_delete=models.CASCADE)
    total_score = models.IntegerField()
    risk_level = models.CharField(max_length=50)
    recommended_specialist = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.patient.name} - {self.risk_level}"


# =========================
# 🆕 NEW: DOCTOR MESSAGE MODEL
# =========================

class DoctorMessage(models.Model):
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    appointment = models.ForeignKey(Appointment, on_delete=models.CASCADE)

    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Message from {self.doctor.name} to {self.patient.name}"