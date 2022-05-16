resource "google_service_account" "certbot" {
  account_id   = "isidro-certbot"
  display_name = "Isidro Certbot"
}

resource "google_project_iam_member" "certbot_dns_admin" {
  project = data.google_project.project.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.certbot.email}"
}

resource "google_project_iam_member" "certbot_workload_identity_user" {
  project = data.google_project.project.project_id
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[isidro/certbot]"
}

