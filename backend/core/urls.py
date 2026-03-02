from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    PatientViewSet,
    HealthProfileViewSet,
    AppointmentViewSet,
    QueryViewSet,
    cancel_appointment,
    get_symptoms,
    get_questions,
    evaluate_triage,
    register_patient,
    patient_history,
    get_doctors,
    custom_login,
    hospital_login,
    doctor_dashboard,
    admin_dashboard,
    send_doctor_message,
    hospital_users,
    my_profile,
    approve_appointment,              # ✅ ADDED
    reject_appointment,               # ✅ ADDED
    send_message_to_appointment       # ✅ ADDED
)

router = DefaultRouter()
router.register(r'patients', PatientViewSet)
router.register(r'healthprofiles', HealthProfileViewSet)
router.register(r'appointments', AppointmentViewSet, basename='appointments')
router.register(r'queries', QueryViewSet)

urlpatterns = [
    path('', include(router.urls)),

    # AUTH
    path('register/', register_patient),
    path('custom-login/', custom_login),
    path('hospital-login/', hospital_login),
    path('my-profile/', my_profile),

    # TRIAGE
    path('symptoms/', get_symptoms),
    path('questions/<int:symptom_id>/', get_questions),
    path('evaluate/', evaluate_triage),

    # HISTORY
    path('history/', patient_history),

    # DOCTORS
    path('doctors/', get_doctors),

    # DASHBOARDS
    path('doctor-dashboard/', doctor_dashboard),
    path('admin-dashboard/', admin_dashboard),

    # PATIENT CANCEL (still allowed)
    path("appointments/<int:pk>/cancel/", cancel_appointment),

    # DOCTOR MESSAGE (old global one)
    path("doctor/send-message/", send_doctor_message),

    # HOSPITAL USERS
    path("hospital-users/", hospital_users),

    # ✅ NEW DOCTOR ACTIONS
    path("appointments/<int:pk>/approve/", approve_appointment),
    path("appointments/<int:pk>/reject/", reject_appointment),
    path("appointments/<int:pk>/message/", send_message_to_appointment),
]