# Graph Report - .  (2026-07-24)

## Corpus Check
- Corpus is ~30,582 words - fits in a single context window. You may not need a graph.

## Summary
- 26 nodes · 24 edges · 7 communities (5 shown, 2 thin omitted)
- Extraction: 83% EXTRACTED · 17% INFERRED · 0% AMBIGUOUS · INFERRED: 4 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Notification Delivery
- Database Schema
- AI Reminder Intelligence
- Migration & Deployment
- Anamneses Migration
- Migration Docs
- Validation Checklist

## God Nodes (most connected - your core abstractions)
1. `AI-Powered Appointment Reminders System` - 6 edges
2. `Complete Database Schema with 11 Tables` - 6 edges
3. `Appointment Reminders Table` - 5 edges
4. `K2-Dent-Production Migration Guide` - 4 edges
5. `Anamneses Table` - 3 edges
6. `Anamnesis Table` - 3 edges
7. `Generate AI Reminders Function` - 2 edges
8. `Patients Table` - 2 edges
9. `Appointments Table` - 2 edges
10. `006 Migration Execution` - 1 edges

## Surprising Connections (you probably didn't know these)
- `Anamnesis Table` --semantically_similar_to--> `Anamneses Table`  [INFERRED] [semantically similar]
  README_MIGRATION.md → MIGRATION_INSTRUCTIONS.md
- `AI-Powered Appointment Reminders System` --conceptually_related_to--> `Appointments Table`  [INFERRED]
  README-AI-Reminders.md → README_MIGRATION.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **AI Appointment Reminder System Architecture** — readme_ai_reminders_appointment_reminders_table, readme_ai_reminders_reminder_ai_config, readme_ai_reminders_pending_reminders_ai_view, readme_ai_reminders_generate_ai_reminders_function, readme_ai_reminders_mark_reminder_sent_function [EXTRACTED 1.00]
- **Database Migration and Deployment Process** — readme_migration_guide, readme_migration_database_schema, readme_migration_deployment_test, readme_migration_validation_checklist [EXTRACTED 1.00]
- **Multi-Channel Notification Delivery** — readme_ai_reminders_twilio_integration, readme_ai_reminders_sendgrid_integration, readme_ai_reminders_cron_automation [EXTRACTED 1.00]

## Communities (7 total, 2 thin omitted)

### Community 0 - "Notification Delivery"
Cohesion: 0.33
Nodes (6): Appointment Reminders Table, Cron Job Automation Pattern, Generate AI Reminders Function, Mark Reminder Sent Function, SendGrid Email Integration Example, Twilio SMS Integration Example

### Community 1 - "Database Schema"
Cohesion: 0.40
Nodes (6): Anamnesis Table, Appointments Table, Complete Database Schema with 11 Tables, Patients Table, Staff Profiles Table, X-Rays Table with AI Analysis

### Community 2 - "AI Reminder Intelligence"
Cohesion: 0.40
Nodes (5): AI Scoring and Prioritization Logic, AI-Powered Appointment Reminders System, Pending Reminders AI View, Reminder AI Configuration Table, Timing Optimization Strategy

### Community 3 - "Migration & Deployment"
Cohesion: 0.50
Nodes (4): Frontend-Database Alignment Strategy, Post-Deployment Testing and Validation, K2-Dent-Production Migration Guide, Row Level Security (RLS) Implementation

### Community 4 - "Anamneses Migration"
Cohesion: 0.67
Nodes (3): 006 Migration Execution, Anamneses Table, Patients Table (Dependency)

## Knowledge Gaps
- **5 isolated node(s):** `Migration Instructions - Anamneses Table`, `006 Migration Execution`, `Twilio SMS Integration Example`, `SendGrid Email Integration Example`, `Cron Job Automation Pattern`
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Complete Database Schema with 11 Tables` connect `Database Schema` to `Migration & Deployment`?**
  _High betweenness centrality (0.570) - this node is a cross-community bridge._
- **Why does `AI-Powered Appointment Reminders System` connect `AI Reminder Intelligence` to `Notification Delivery`, `Database Schema`?**
  _High betweenness centrality (0.533) - this node is a cross-community bridge._
- **Why does `Appointments Table` connect `Database Schema` to `AI Reminder Intelligence`?**
  _High betweenness centrality (0.440) - this node is a cross-community bridge._
- **What connects `Migration Instructions - Anamneses Table`, `006 Migration Execution`, `Twilio SMS Integration Example` to the rest of the system?**
  _5 weakly-connected nodes found - possible documentation gaps or missing edges._