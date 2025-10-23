# Feature Specification: Ship Collision Detection API

**Feature Branch**: `001-collision-detection-api`  
**Created**: 2025-10-21  
**Status**: Draft  
**Input**: User description: "I am building a web server application. It is a Ship Coordinatation Service which is responsible for ensuring the safety of maritime traffic in the ocea. The primary goal of the service is to handle butch of ships request via open api with given coordinates and inform the crew about the possible collision within a time range (1 minute). Additional functionality like authorisation, rbac, etc, could be added latter but not mandatory for now. Project should be as much as possible close to real production app, so such systems as perfomance metrics, central logging system, profilling, cache (if needed), testing should be implemented. Should be preppered test cases for benchmarking to track perfomance. Application should show the real SDLC so it is connected to jira board. Primary Application stack is Node.js v22+ with typescript"

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Ship Position Reporting (Priority: P1)

Ship operators submit their vessel's position history (coordinates with timestamps) to the coordination service via an API endpoint. The system accepts the position data, automatically calculates speed and heading from the position history, and stores this information for collision detection processing.

**Why this priority**: This is the foundational capability. Without ships reporting positions, no collision detection is possible. This represents the core data ingestion pipeline with intelligent speed/heading calculation.

**Independent Test**: Can be fully tested by sending ship position history (minimum 2 points with coordinates and timestamps) via API, verifying successful acceptance (HTTP 201), automatic calculation of speed and heading, and data persistence. Delivers immediate value by establishing the position tracking registry with automated trajectory analysis.

**Acceptance Scenarios**:

1. **Given** a ship submits at least 2 historical position points (each with latitude, longitude, and timestamp), **When** the system processes the data, **Then** it automatically calculates speed (based on distance between last 2 points and time difference) and heading (direction between last 2 points), stores the calculated values, and returns confirmation
2. **Given** a ship submits 3 or more historical position points, **When** the system processes the data, **Then** it uses the two most recent points to calculate current speed and heading
3. **Given** multiple ships send position updates simultaneously, **When** the batch of requests arrives, **Then** all valid positions are recorded, speed/heading calculated for each, without data loss
4. **Given** a ship sends only 1 position point (no history for calculation), **When** the request is processed, **Then** the system accepts the position but cannot calculate speed/heading (defaults to stationary: 0 knots, heading unknown)
5. **Given** a ship sends position data with missing required fields (latitude, longitude, or timestamp), **When** the request is processed, **Then** the system rejects it with a clear validation error message
6. **Given** a ship sends position points with identical timestamps, **When** the duplicate timestamps are detected, **Then** the system rejects the request (cannot calculate speed with zero time difference)

---

### User Story 2 - Trajectory Validation and Collision Risk Detection (Priority: P1)

When a ship submits position updates, the system calculates its projected trajectory (series of future positions) for the next 60 seconds based on current speed and heading. The system then validates this trajectory against all other vessels' trajectories to determine if any collision risks exist. The response immediately informs the vessel of the worst-case collision status along its projected path.

**Why this priority**: This is the core safety feature - validating the vessel's planned path and detecting imminent collisions along the entire trajectory, not just the endpoint. Without this, the service provides no safety value. Tied with P1 because position reporting and trajectory validation form the minimum viable product.

**Independent Test**: Can be fully tested by submitting positions for two ships on a collision course, verifying that the system projects trajectories for next 60 seconds, validates path intersections, and returns the most dangerous collision status within acceptable latency (< 2 seconds). Delivers immediate safety value with predictive path analysis.

**Acceptance Scenarios**:

1. **Given** a vessel submits position update, **When** the system processes the request, **Then** it calculates a series of future positions (time and coordinates) for the next 60 seconds based on current speed and heading, validates this trajectory against all other vessels' trajectories, and returns the most dangerous collision status (DANGER/WARNING/SAFE) found along the path
2. **Given** two ships are moving on intersecting paths, **When** trajectory validation runs, **Then** the system detects any point along either trajectory where vessels will be within 500m and returns DANGER (0-100m), WARNING (100-500m), or SAFE (>500m) status based on the closest projected approach
3. **Given** ships are on parallel non-intersecting courses, **When** trajectory validation runs, **Then** all future positions remain >500m apart, status returns SAFE (green), and trajectory is considered safe
4. **Given** a vessel has multiple potential collisions with different ships along its 60-second trajectory, **When** validation runs, **Then** the system returns the most dangerous status encountered (DANGER takes precedence over WARNING, WARNING over SAFE)
5. **Given** a ship submits two position points with identical coordinates (latitude and longitude), **When** the system detects no movement, **Then** the vessel is marked as stationary/static with speed = 0 knots and heading = undefined
6. **Given** a stationary vessel and a moving vessel whose trajectory passes within proximity range, **When** validation runs, **Then** collision risk is detected based on the moving vessel's projected path intersecting the static vessel's position

---

### User Story 3 - Real-time Trajectory Safety Response (Priority: P1)

When a vessel submits position data, the system immediately responds with trajectory safety analysis - informing the vessel what collision risks exist if it continues on its current course and speed for the next 60 seconds. The response includes the worst-case collision status encountered along the projected path and details about potential collisions.

**Why this priority**: Immediate trajectory safety feedback allows vessels to make informed navigation decisions in real-time. This completes the core safety loop (report → calculate trajectory → validate path → respond with safety status).

**Independent Test**: Can be fully tested by submitting position update and verifying that the response contains trajectory safety status (DANGER/WARNING/SAFE), projected collision points, and details about other vessels within acceptable response time (< 200ms). Delivers complete safety value with actionable guidance.

**Acceptance Scenarios**:

1. **Given** a vessel submits position update, **When** the system completes trajectory validation, **Then** the API response immediately returns: trajectory safety status (DANGER/WARNING/SAFE), list of vessels along collision path (if any), time to closest approach for each risk, and projected positions at risk points
2. **Given** a vessel's trajectory validation returns DANGER status (projected approach < 100m), **When** the response is generated, **Then** it includes urgent/critical indicator (red), all vessels causing DANGER status, exact time(s) when minimum distance occurs, and recommended action (alter course/speed)
3. **Given** a vessel's trajectory validation returns WARNING status (projected approach 100-500m) with no DANGER risks, **When** the response is generated, **Then** it includes caution indicator (yellow), all vessels in WARNING range, and suggested awareness of nearby traffic
4. **Given** a vessel's trajectory is completely SAFE (all other vessels > 500m throughout 60s), **When** the response is generated, **Then** it includes SAFE status (green) with confirmation that current course and speed are safe to continue
5. **Given** a stationary vessel (identical position points), **When** trajectory validation runs, **Then** the response indicates the vessel is static and validates if any moving vessels' trajectories will intersect its position

---

### User Story 4 - Ship Registration and Management (Priority: P2)

Ships can register with the coordination service by providing vessel details (name, IMO number, MMSI, vessel type, dimensions). Registered ships receive API credentials for position reporting and alerts.

**Why this priority**: While important for production operations (tracking ship identity, managing access), the core MVP can function with ship IDs alone. Registration adds operational context but isn't required for basic collision detection.

**Independent Test**: Can be fully tested by registering a new ship via API, receiving credentials, and using those credentials to report positions. Delivers identity management and access control.

**Acceptance Scenarios**:

1. **Given** a ship operator wants to join the service, **When** they submit vessel details (name, IMO, MMSI, dimensions, contact info), **Then** the system creates a ship record and provides API credentials
2. **Given** a ship attempts to register with an IMO or MMSI already in the system, **When** the duplicate is detected, **Then** the system rejects the registration with an appropriate error
3. **Given** a registered ship, **When** the ship updates its profile information, **Then** the changes are saved and reflected in future collision alerts
4. **Given** a ship is decommissioned or leaves the service, **When** the ship is deregistered, **Then** it can no longer submit positions or receive alerts

---

### User Story 5 - Historical Position Tracking (Priority: P3)

The system maintains a historical log of all ship positions over time. Users can query past positions for a specific ship or time range for incident investigation, route analysis, or compliance reporting.

**Why this priority**: Historical data is valuable for post-incident analysis and operational insights, but not required for real-time collision prevention. This is an enhancement that adds forensic and analytical capabilities.

**Independent Test**: Can be fully tested by submitting positions over time, then querying historical data and verifying accuracy and completeness. Delivers audit trail and analytics capability.

**Acceptance Scenarios**:

1. **Given** a ship has been reporting positions for several hours, **When** a user queries position history for that ship, **Then** all historical positions are returned in chronological order
2. **Given** a specific time range, **When** a user requests all ship positions within that period, **Then** the system returns matching positions for all ships
3. **Given** a collision incident occurred at a specific time, **When** investigators query positions near that time, **Then** they can reconstruct the movements of involved vessels

---

### User Story 6 - Performance Monitoring and Metrics (Priority: P2)

The system exposes real-time performance metrics including request throughput, collision detection latency, active ship count, and system health indicators. Operations teams can monitor service health and performance trends.

**Why this priority**: Essential for production operations and meeting performance SLAs, but not required for the core safety feature to function. This enables operational excellence and proactive issue detection.

**Independent Test**: Can be fully tested by generating load, accessing metrics endpoints, and verifying accurate reporting of throughput, latency, and system status. Delivers operational visibility.

**Acceptance Scenarios**:

1. **Given** the service is running under normal load, **When** metrics are queried, **Then** current values for request rate, collision detection latency, active ships, and error rate are returned
2. **Given** the service is under heavy load, **When** performance degrades, **Then** metrics accurately reflect the degradation and alert thresholds are triggered
3. **Given** a time-series metrics system, **When** metrics are collected over time, **Then** trends can be visualized for capacity planning and performance optimization

---

### Edge Cases

- What happens when a ship sends invalid coordinates (out of range, non-numeric)?
- How does the system handle ships with identical coordinates in consecutive position points (stationary vessels)?
- What happens when position data is stale (timestamp > 5 minutes old)?
- How does the system calculate speed/heading when only 1 position point is provided (no historical data)?
- What happens when position points have identical timestamps (zero time difference)?
- What happens when calculated speed is unrealistically high (e.g., ship "moving" faster than physically possible)?
- How does the system handle position points submitted out of chronological order?
- What happens when trajectory projection extends beyond 60 seconds due to calculation complexity?
- How many future points should be calculated along the 60-second trajectory (granularity)?
- What happens when two vessels' trajectories run exactly parallel at boundary distance (exactly 100m or 500m)?
- How does the system handle trajectory validation when hundreds of vessels have intersecting paths?
- What happens when collision detection calculations encounter edge cases (ships at poles, crossing the international date line)?
- How does the system perform when ship count exceeds expected capacity?
- What happens when two ships report conflicting positions for the same vessel ID?
- How does the system handle very slow-moving vessels (speed < 1 knot) - static or moving?
- What happens when a vessel changes course between position updates (trajectory prediction becomes inaccurate)?

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: System MUST accept ship position updates via a RESTful API endpoint accepting vessel ID and an array of position history points (each containing latitude, longitude, and timestamp)
- **FR-002**: System MUST validate all position data for completeness and plausibility (latitude -90 to 90, longitude -180 to 180, timestamp is valid ISO 8601 format)
- **FR-003**: System MUST automatically calculate vessel speed in knots by measuring the distance between the last two position points and dividing by the time difference
- **FR-004**: System MUST automatically calculate vessel heading in degrees (0-359) by determining the bearing from the second-to-last position point to the last position point
- **FR-005**: System MUST detect stationary vessels by identifying when two consecutive position points have identical coordinates (latitude and longitude), marking speed as 0 knots and heading as undefined
- **FR-006**: System MUST handle single-point submissions gracefully by accepting the position but marking speed as 0 knots and heading as unknown/undefined
- **FR-007**: System MUST reject position submissions where multiple points have identical timestamps (cannot calculate speed with zero time difference)
- **FR-008**: System MUST use the WGS84 geodetic system and Haversine formula (or equivalent) for accurate distance calculations between coordinates
- **FR-009**: System MUST persist all received position points along with calculated speed and heading values, with millisecond-precision timestamps
- **FR-010**: For each position update, system MUST calculate a projected trajectory consisting of a series of future positions (time and coordinates) for the next 60 seconds based on current position, calculated speed, and calculated heading
- **FR-011**: System MUST project trajectory points at regular intervals (reasonable default: every 5 seconds = 12 points total over 60 seconds) to enable accurate path validation
- **FR-012**: System MUST validate the submitting vessel's projected trajectory against all other active vessels' (updated within last 2 minutes) projected trajectories
- **FR-013**: System MUST check each point along the submitting vessel's trajectory against each point along other vessels' trajectories to determine minimum approach distance
- **FR-014**: System MUST classify collision risk at each trajectory intersection point into three severity levels: DANGER (0-100m), WARNING (100-500m), SAFE (>500m)
- **FR-015**: System MUST determine the worst-case collision status along the entire 60-second trajectory (DANGER takes precedence over WARNING, WARNING over SAFE)
- **FR-016**: System MUST return trajectory safety status in the API response to position updates, including: overall status (DANGER/WARNING/SAFE), list of vessels causing risks, time to closest approach for each risk, and projected positions at risk points
- **FR-017**: System MUST complete trajectory calculation and validation within 200 milliseconds to provide real-time response
- **FR-018**: System MUST validate stationary vessels' positions against moving vessels' trajectories to detect if any trajectory intersects the static position
- **FR-019**: System MUST support ship registration with vessel details (name, IMO number, MMSI, type, dimensions)
- **FR-020**: System MUST generate unique API credentials for registered ships
- **FR-021**: System MUST authenticate API requests using provided credentials
- **FR-022**: System MUST maintain historical position records for all ships for a minimum of 30 days
- **FR-023**: System MUST provide query endpoints for historical position data by ship ID and time range
- **FR-024**: System MUST expose performance metrics including: request throughput, trajectory validation latency, active ship count, error rate, and system uptime
- **FR-025**: System MUST log all API requests, trajectory calculations, collision validations, and safety responses with structured JSON format
- **FR-026**: System MUST handle concurrent position updates from multiple ships without data loss
- **FR-027**: System MUST reject malformed or invalid requests with appropriate HTTP status codes and error messages
- **FR-028**: System MUST support batch position updates (multiple ships in a single request) to optimize network efficiency
- **FR-029**: System MUST implement rate limiting to prevent abuse (reasonable default: 100 requests per minute per ship)
- **FR-030**: System MUST flag and log unrealistic calculated speeds (e.g., >50 knots for cargo vessels) for review but still process the position update and trajectory

### Key Entities

- **Ship**: Represents a maritime vessel in the system. Attributes include unique identifier (UUID), name, IMO number (international vessel ID), MMSI (maritime mobile service identity), vessel type (cargo, tanker, passenger, etc.), dimensions (length, beam, draft), registration timestamp, and API credentials.

- **Position**: Represents a ship's location and movement state at a specific point in time. Attributes include ship reference, latitude (decimal degrees), longitude (decimal degrees), timestamp (ISO 8601 with milliseconds), calculated speed (knots - derived from distance between this point and previous point divided by time difference), calculated heading (degrees 0-359 - derived from bearing between previous point and this point), and record ID.

- **Trajectory**: Represents a vessel's projected path for the next 60 seconds. Attributes include vessel reference, base position (starting point), calculated speed (knots), calculated heading (degrees), array of future points (each with projected time offset in seconds and projected coordinates), calculation timestamp, and trajectory validity period.

- **TrajectoryPoint**: Represents a single point along a projected trajectory. Attributes include time offset from current position (0-60 seconds), projected latitude, projected longitude, and distance from base position.

- **CollisionRisk**: Represents a detected potential collision between two vessels along their trajectories. Attributes include involved vessel references (vessel A, vessel B), detection timestamp, time to closest approach (seconds), projected minimum distance (meters), trajectory points where minimum distance occurs (for both vessels), relative bearing (degrees), severity status (DANGER: 0-100m / red, WARNING: 100-500m / yellow, SAFE: >500m / green), and resolution status (active/resolved).

- **TrajectorySafetyResponse**: Represents the real-time safety analysis returned in API response. Attributes include requesting vessel reference, overall trajectory status (DANGER/WARNING/SAFE), array of collision risks (if any), trajectory validity (60 seconds from request time), and recommended actions (if status is not SAFE).

- **Metric**: Represents a system performance measurement at a point in time. Attributes include metric name, value, timestamp, and optional labels/tags for aggregation.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: System successfully accepts and processes 1,000+ position updates per second without data loss or errors
- **SC-002**: Trajectory calculation and validation completes within 200 milliseconds at 95th percentile for scenarios with up to 10,000 active ships
- **SC-003**: Position update API returns trajectory safety response within 250 milliseconds at 95th percentile under normal load
- **SC-004**: System maintains 99.9% uptime during normal operations
- **SC-005**: Trajectory validation accurately detects 100% of collision risks along projected paths in benchmark scenarios
- **SC-006**: Zero false negatives in collision detection (all genuine collision risks within 500m are detected) in benchmark scenarios
- **SC-007**: Collision severity classification is 100% accurate (DANGER for 0-100m, WARNING for 100-500m, SAFE for >500m) in test scenarios
- **SC-008**: False positive rate for collision detection is below 5% in benchmark scenarios
- **SC-009**: Speed calculation accuracy is within ±0.1 knots of actual vessel speed in test scenarios with accurate GPS data
- **SC-010**: Heading calculation accuracy is within ±2 degrees of actual vessel heading in test scenarios
- **SC-011**: Trajectory projection accuracy maintains ±50 meters position error over 60-second projection in test scenarios with constant vessel speed/heading
- **SC-012**: System correctly identifies stationary vessels (identical coordinates) with 100% accuracy
- **SC-013**: Worst-case collision status determination is correct in 100% of multi-risk scenarios (DANGER precedence over WARNING over SAFE)
- **SC-014**: Ship registration and credential generation completes within 500 milliseconds
- **SC-015**: Historical position queries return results within 1 second for time ranges up to 24 hours
- **SC-016**: System performance metrics are available with less than 10 seconds latency from actual events
- **SC-017**: 100% of API requests are logged with complete request/response details including trajectory calculations for audit and debugging
- **SC-018**: System can scale horizontally to support 100,000+ registered ships and 50,000+ active ships simultaneously with maintained response times

## Assumptions

- Ships report position history voluntarily; the system does not actively track vessels via radar or AIS integration (this may be added later)
- All position coordinates use the WGS84 datum (standard GPS coordinate system)
- Ships submit position history with at least 2 points for accurate speed/heading calculation; single-point submissions are accepted but treated as stationary
- Position updates are submitted frequently enough (recommended every 30-60 seconds) to maintain accurate trajectory calculations and provide timely collision warnings
- Ships maintain relatively constant speed and heading between position updates (no sudden course changes without new position reports) - trajectory projections assume straight-line travel
- Trajectory projection granularity of 5-second intervals (12 points over 60 seconds) provides sufficient accuracy to detect collision risks while maintaining performance
- The Haversine formula provides sufficient accuracy for distance calculations (alternative: Vincenty formula for higher precision if needed)
- The 60-second prediction window is sufficient for crew reaction time to take evasive action
- Stationary vessels are identified by identical coordinates in consecutive position points (latitude and longitude match exactly or within < 1 meter)
- Trajectory validation completes synchronously within API response time (< 200ms) rather than async processing
- Ship dimensions and turning capabilities are not considered in initial collision detection (point-to-point distance with straight-line trajectory projection is acceptable for MVP)
- Ships operating in close quarters (e.g., ports, narrow channels) may trigger alerts that are operationally normal; advanced filtering (geofencing, port exclusion zones) can be added later
- The service operates globally without regional restrictions or geofencing in MVP
- Calculated speed and heading from GPS positions are sufficiently accurate for collision detection (typical GPS accuracy: ±5-10 meters translates to acceptable trajectory projection error)
- For performance, trajectory validation only checks against active vessels (updated within last 2 minutes); older positions are excluded from real-time collision checking
- The worst-case collision status (DANGER > WARNING > SAFE) along the entire 60-second path provides actionable guidance for vessel navigation decisions
