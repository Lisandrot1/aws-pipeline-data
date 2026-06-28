# data-pipeline-aws

AWS Data Pipeline infrastructure using Terraform.

## Infrastructure Structure

api_logs
root
 |-- api_log_id: string (nullable = true)
 |-- request_id: string (nullable = true)
 |-- user_id: string (nullable = true)
 |-- session_id: string (nullable = true)
 |-- timestamp: string (nullable = true)
 |-- endpoint: string (nullable = true)
 |-- method: string (nullable = true)
 |-- payload_size_bytes: integer (nullable = true)
 |-- status_code: integer (nullable = true)
 |-- latency_ms: integer (nullable = true)
 |-- body_size_bytes: integer (nullable = true)
 |-- instance_id: string (nullable = true)
 |-- region: string (nullable = true)
 |-- service: string (nullable = true)
 |-- year: string (nullable = true)
 |-- month: string (nullable = true)
 |-- day: string (nullable = true)

errors
root
 |-- error_id: string (nullable = true)
 |-- api_log_id: string (nullable = true)
 |-- timestamp: string (nullable = true)
 |-- error_type: string (nullable = true)
 |-- severity: string (nullable = true)
 |-- is_retryable: boolean (nullable = true)
 |-- message: string (nullable = true)
 |-- caused_by: string (nullable = true)
 |-- environment: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- instance_id: string (nullable = true)
 |-- year: string (nullable = true)
 |-- month: string (nullable = true)
 |-- day: string (nullable = true)
 |-- _orphan: boolean (nullable = true)

events
root
 |-- event_id: string (nullable = true)
 |-- session_id: string (nullable = true)
 |-- user_id: string (nullable = true)
 |-- event_name: string (nullable = true)
 |-- event_category: string (nullable = true)
 |-- timestamp: string (nullable = true)
 |-- feature_name: string (nullable = true)
 |-- action: string (nullable = true)
 |-- duration_ms: integer (nullable = true)
 |-- status: string (nullable = true)
 |-- page: string (nullable = true)
 |-- referrer: string (nullable = true)
 |-- locale: string (nullable = true)
 |-- year: string (nullable = true)
 |-- month: string (nullable = true)
 |-- day: string (nullable = true)

sessions
root
 |-- session_id: string (nullable = true)
 |-- user_id: string (nullable = true)
 |-- started_at: string (nullable = true)
 |-- ended_at: string (nullable = true)
 |-- duration_seconds: integer (nullable = true)
 |-- type: string (nullable = true)
 |-- os: string (nullable = true)
 |-- app_version: string (nullable = true)
 |-- pages_visited: integer (nullable = true)
 |-- events_count: integer (nullable = true)
 |-- errors_encountered: integer (nullable = true)
 |-- ip_address: string (nullable = true)
 |-- country: string (nullable = true)
 |-- city: string (nullable = true)
 |-- year: string (nullable = true)
 |-- month: string (nullable = true)
 |-- day: string (nullable = true)

user_signups
root
 |-- signup_id: string (nullable = true)
 |-- user_id: string (nullable = true)
 |-- email: string (nullable = true)
 |-- full_name: string (nullable = true)
 |-- created_at: string (nullable = true)
 |-- plan_initial: string (nullable = true)
 |-- completed: boolean (nullable = true)
 |-- steps_completed: integer (nullable = true)
 |-- total_steps: integer (nullable = true)
 |-- abandoned_at_step: string (nullable = true)
 |-- type: string (nullable = true)
 |-- browser: string (nullable = true)
 |-- os: string (nullable = true)
 |-- email_verified: boolean (nullable = true)
 |-- email_verified_at: string (nullable = true)
 |-- country: string (nullable = true)
 |-- country_name: string (nullable = true)
 |-- city: string (nullable = true)
 |-- source: string (nullable = true)
 |-- referral_code: string (nullable = true)
 |-- year: string (nullable = true)
 |-- month: string (nullable = true)
 |-- day: string (nullable = true)
​
