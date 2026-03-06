# Seed Data Reference

The study plan in `lib/data/seed/plan_seed.dart` contains 10 weeks translated from a JSX source.

## Week-by-Week Summary

| Week | Phase          | Title                                    | Color   |
|------|----------------|------------------------------------------|---------|
| 1    | CONTAINERS     | Docker + Your First Deployable API       | #0EA5E9 |
| 2    | INFRASTRUCTURE | Terraform + AWS Networking Foundation    | #6366F1 |
| 3    | INFRASTRUCTURE | ECS Fargate + Production Deploy          | #6366F1 |
| 4    | AUTOMATION     | CI/CD Pipeline + GitHub Actions          | #F59E0B |
| 5    | AUTOMATION     | Multi-Env + Security Scanning            | #F59E0B |
| 6    | CERT           | SAA-C03 Exam Sprint                      | #EF4444 |
| 7    | CERT           | Exam Week + Post-Exam Build              | #EF4444 |
| 8    | CAPSTONE       | Full Platform Build                      | #10B981 |
| 9    | CAPSTONE       | Chaos Engineering + Production Readiness | #10B981 |
| 10   | LAUNCH         | Portfolio + Launch                       | #D946EF |

## Task Structure

Each week has:
- **fridayTasks**: 3-5 TaskItems (day="friday")
- **saturdayTasks**: 3-5 TaskItems (day="saturday")
- **weeknightSaa**: Text description of SAA study for that week
- **weeknightSchedule**: How to split the SAA study across weeknights

Each TaskItem gets a UUID v4 at seed time. IDs are stable after first seed (stored in Hive).

## Additional Data

- `rules`: String constant with 6 study rules
- `bufferNotes`: String constant explaining the buffer week system
- `costSummary`: String constant with cost breakdown (mostly free tier)

## Phase Color Map

```
CONTAINERS:     bg=#EFF6FF, border=#0EA5E9, text=#0369A1
INFRASTRUCTURE: bg=#EEF2FF, border=#6366F1, text=#4338CA
AUTOMATION:     bg=#FFFBEB, border=#F59E0B, text=#B45309
CERT:           bg=#FEF2F2, border=#EF4444, text=#B91C1C
CAPSTONE:       bg=#ECFDF5, border=#10B981, text=#047857
LAUNCH:         bg=#FDF4FF, border=#D946EF, text=#A21CAF
```
