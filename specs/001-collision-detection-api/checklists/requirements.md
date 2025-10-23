# Specification Quality Checklist: Ship Collision Detection API

**Purpose**: Validate specification completeness and quality before proceeding to planning  
**Created**: 2025-10-21  
**Feature**: [../spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

**✅ All Validation Items Passed**

Major specification enhancements (latest update: 2025-10-23):

### 1. Three-tier collision severity system

DANGER (0-100m / red), WARNING (100-500m / yellow), SAFE (>500m / green)

### 2. Automatic speed and heading calculation

Ships submit coordinates + timestamps (minimum 2 points)

- Speed: distance between last 2 points / time difference
- Heading: bearing between last 2 points
- Stationary vessels: identical coordinates → speed = 0, heading = undefined

### 3. **Trajectory-based collision validation** (MAJOR ENHANCEMENT)

Instead of checking only endpoint collision, system now:

- **Projects full 60-second trajectory** for each vessel (series of future positions every 5 seconds = 12 points)
- **Validates entire path** against all other vessels' trajectories
- **Returns worst-case status** immediately in API response (DANGER > WARNING > SAFE)
- Answers: "What's the collision risk if I continue this course/speed for 60 seconds?"

**Key Algorithm Changes:**

- Trajectory calculation: Current position + speed + heading → 12 future points (0, 5s, 10s, ..., 60s)
- Path validation: Check each point on vessel's trajectory vs. all points on other vessels' trajectories
- Precedence: If any point shows DANGER, entire trajectory = DANGER; else if WARNING exists, trajectory = WARNING; else SAFE
- Real-time response: Trajectory safety returned synchronously in position update API response (< 200ms)

**Updated Sections:**

- User Story 2: "Trajectory Validation and Collision Risk Detection"
- User Story 3: "Real-time Trajectory Safety Response" (replaces alert delivery)
- FR-010 to FR-018: Trajectory calculation, validation, and response requirements (total 30 FRs now)
- New entities: Trajectory, TrajectoryPoint, TrajectorySafetyResponse
- Updated CollisionRisk entity to reference trajectory points
- New success criteria: SC-011 (trajectory accuracy), SC-012 (stationary detection), SC-013 (precedence logic)
- 16 edge cases covering trajectory calculation scenarios

**API Response Evolution:**

```
Before: HTTP 201 Created (position accepted)
After: HTTP 200 OK with trajectory safety analysis
{
  "status": "DANGER",
  "risks": [
    {
      "vessel": "ship-456",
      "timeToClosestApproach": 32,
      "minimumDistance": 75,
      "severity": "DANGER"
    }
  ],
  "trajectoryValidUntil": "2025-10-23T10:03:00Z"
}
```

**Specification Status**: Ready for `/speckit.plan` to create implementation plan

**Branch Naming Note**: Current branch is `001-collision-detection-api`. User prefers format `BTS-<number>-feature_name`. Consider updating branch creation script for future features.
