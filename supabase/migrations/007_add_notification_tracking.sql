-- Migration: Add notification tracking columns to appointments table
-- Created: 2026-07-24
-- Purpose: Track email and SMS notification delivery timestamps for audit trail and status visibility

-- Add notification timestamp columns
ALTER TABLE appointments
  ADD COLUMN IF NOT EXISTS email_sent_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS sms_sent_at TIMESTAMPTZ;

-- Add indexes for querying notification status
CREATE INDEX IF NOT EXISTS idx_appointments_email_sent_at ON appointments(email_sent_at);
CREATE INDEX IF NOT EXISTS idx_appointments_sms_sent_at ON appointments(sms_sent_at);

-- Add comment for documentation
COMMENT ON COLUMN appointments.email_sent_at IS 'Timestamp when confirmation/reminder email was sent to patient';
COMMENT ON COLUMN appointments.sms_sent_at IS 'Timestamp when confirmation/reminder SMS was sent to patient';
