from django.contrib import admin

from .models import (
    Doctor,   # ✅ ADD THIS
    Patient,
    HealthProfile,
    Appointment,
    Query,
    Symptom,
    Question,
    AnswerChoice,
    TriageResult
)

# Register Doctor first
admin.site.register(Doctor)

# Existing models
admin.site.register(Patient)
admin.site.register(HealthProfile)
admin.site.register(Appointment)
admin.site.register(Query)

# Triage models
admin.site.register(Symptom)
admin.site.register(Question)
admin.site.register(AnswerChoice)
admin.site.register(TriageResult)