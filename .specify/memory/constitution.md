<!--
Sync Impact Report:
- Version change: 0.0.0 → 1.0.0 (REVISED)
- New constitution created for Marine Traffic project
- Principles defined (pragmatic Node.js approach):
  1. Domain/Transport Separation (pragmatic, not strict DDD)
  2. Type-Safe Contract-First Development
  3. Test-Driven Development (TDD) - NON-NEGOTIABLE
  4. RESTful API Design Standards
  5. Observability & Structured Logging
  6. Schema-First OpenAPI Generation
  7. Fastify Patterns & Plugin Architecture
- Templates requiring updates:
  ✅ plan-template.md - Constitution Check updated for pragmatic Node.js patterns
  ✅ spec-template.md - Already aligned with REST endpoints and user stories
  ✅ tasks-template.md - Task organization simplified for Fastify plugin/route architecture
- Follow-up TODOs: None
-->

# Marine Traffic Constitution

## Core Principles

### I. Domain/Transport Separation

**Business logic and web framework concerns must be kept separate. Keep it simple and pragmatic.**

- **Two-tier architecture** (not strict DDD):
  - `src/domain/` — Business logic: functions, classes, entities, business rules. NO Fastify/HTTP dependencies.
  - `src/routes/` or `src/plugins/` — Fastify routes, hooks, decorators, request/response handling, validation.
  - `src/lib/` or `src/utils/` — Shared utilities, database connections, helpers.
  - `src/schemas/` — Zod schemas for validation and OpenAPI generation.

- **Simple database access patterns**:
  - Use plain functions or simple classes for database operations
  - Keep queries close to where they're used (in domain modules or dedicated `src/db/` folder)
  - NO need for repository interfaces or complex abstractions unless they serve a clear purpose
  - Direct use of PostgreSQL client (`pg`) or query builder (Kysely) is fine

- **No DTOs or excessive mapping**:
  - Zod schemas handle validation and type inference
  - Domain functions work with plain objects or simple classes
  - Only create dedicated types/classes when they add clear value (encapsulation, methods, validation)

- **Pragmatic separation example**:

  ```typescript
  // ✅ GOOD: Domain logic separate from transport
  // src/domain/ships/collision-detector.ts
  export function detectCollision(ship1: Ship, ship2: Ship): boolean {
    // Pure business logic, no Fastify/HTTP
  }

  // src/routes/ships.ts
  export default async function (fastify: FastifyInstance) {
    fastify.post('/ships/detect-collision', {
      schema: { body: collisionRequestSchema }
    }, async (request, reply) => {
      const result = detectCollision(request.body.ship1, request.body.ship2);
      return { collision: result };
    });
  }

  // ❌ BAD: Business logic mixed with HTTP handling
  fastify.post('/ships/detect-collision', async (request, reply) => {
    const distance = Math.sqrt(...); // business logic in route handler
    if (distance < threshold) { /* ... */ }
  });
  ```

**Rationale**: Node.js thrives on simplicity. Separate domain logic so it's testable without HTTP context, but avoid over-engineering with layers that don't add value.

---

### II. Type-Safe Contract-First Development

**Zod schemas are the single source of truth for all request/response contracts. Type safety is non-negotiable.**

- **All API contracts MUST be defined as Zod schemas** in `src/shared/schemas/` or per-domain schema files
- **Zod schemas MUST be validated at runtime** for all incoming requests (Fastify validation)
- **TypeScript types MUST be derived from Zod** using `z.infer<>` — never write duplicate type definitions
- **Zod schemas MUST be automatically converted to OpenAPI** specifications
  - Use `@fastify/swagger` or `zod-to-openapi` for automatic generation
  - Generated OpenAPI written to `public/openapi.yaml` on build
- **Client-side types MUST be generated from OpenAPI** for full type safety across client-server boundary

**Rationale**: Contract-first development catches integration errors at compile time, eliminates manual API documentation, and ensures clients and servers stay in sync automatically.

---

### III. Test-Driven Development (TDD) — NON-NEGOTIABLE

**Tests are written BEFORE implementation. Code that ships without tests is unacceptable.**

- **Red-Green-Refactor cycle strictly enforced**:
  1. Write test (must fail)
  2. Get user/peer approval on test scenarios
  3. Implement minimal code to pass test
  4. Refactor for quality

- **Test coverage targets**:
  - **Domain layer**: ≥ 90% coverage (unit tests)
  - **Application layer**: ≥ 80% coverage (unit + integration tests)
  - **Infrastructure layer**: ≥ 70% coverage (integration tests with test database)
  - **API layer**: ≥ 80% coverage (contract + integration tests)

- **Test types required**:
  - **Unit tests**: Pure domain logic, no dependencies
  - **Integration tests**: Database interactions, use in-memory PostgreSQL or test containers
  - **Contract tests**: Validate OpenAPI spec matches actual API behavior (using generated schemas)
  - **End-to-end tests** (optional but recommended): Full request/response validation

- **Test isolation**:
  - Tests MUST NOT depend on execution order
  - Each test MUST set up and tear down its own data
  - Use factories/fixtures for test data generation

**Rationale**: TDD ensures correctness from the start, reduces bugs, enables fearless refactoring, and serves as living documentation.

---

### IV. RESTful API Design Standards

**APIs MUST follow REST principles and HTTP semantics correctly.**

- **Resource-based URLs** with proper HTTP methods:
  - `GET /v1/ships` — List resources (with pagination: ?limit=20&offset=0)
  - `POST /v1/ships` — Create resource
  - `GET /v1/ships/:id` — Retrieve single resource
  - `PUT /v1/ships/:id` — Update resource (full replacement)
  - `PATCH /v1/ships/:id` — Partial update
  - `DELETE /v1/ships/:id` — Delete resource

- **HTTP status codes MUST be used correctly**:
  - `200 OK` — Successful GET/PUT/PATCH
  - `201 Created` — Successful POST (with Location header)
  - `204 No Content` — Successful DELETE
  - `400 Bad Request` — Validation errors (with structured error body)
  - `404 Not Found` — Resource does not exist
  - `409 Conflict` — Duplicate or constraint violation
  - `422 Unprocessable Entity` — Semantic validation failure
  - `500 Internal Server Error` — Unexpected errors (no stack trace leak)

- **Pagination MUST be implemented** for all list endpoints:
  - Use query params: `?limit=X&offset=Y`
  - Response includes: `{ data: [...], total: N, limit: X, offset: Y }`
  - Validate and cap limit (max 100 items per page)

- **Versioning**:
  - API version in URL path: `/v1/...`
  - Version increments follow semantic versioning (see Principle VII)

- **Error responses MUST be structured**:
  ```json
  {
    "error": {
      "code": "VALIDATION_ERROR",
      "message": "Invalid ship data",
      "details": [{"field": "imo", "message": "IMO must be 7 digits"}]
    }
  }
  ```

**Rationale**: Consistent REST design reduces cognitive load, enables client generation, and follows industry best practices for HTTP APIs.

---

### V. Observability & Structured Logging

**Production systems MUST be observable. Logging, metrics, and tracing are first-class concerns.**

- **Structured logging with Pino**:
  - All logs MUST be JSON formatted: `{ level, timestamp, msg, context }`
  - Use correlation IDs (request ID) for tracing requests across layers
  - Log levels: `trace` (dev only), `debug`, `info`, `warn`, `error`, `fatal`
  - NO sensitive data in logs (passwords, tokens, PII)

- **What to log**:
  - **Request/Response**: HTTP method, path, status, duration, user ID
  - **Domain events**: Ship created, collision detected, position updated
  - **Errors**: Full stack trace (internal logs only), error code + message (API response)
  - **Performance**: Slow queries (> 500ms), high memory usage

- **Metrics with TIG stack** (Telegraf, InfluxDB, Grafana):
  - Request rate, error rate, latency (p50, p95, p99)
  - Database query performance
  - Active connections, memory usage
  - Domain-specific metrics: ships tracked, collision alerts sent
  - Metrics configuration in `infra/metrics/`

- **Future: Distributed tracing** (OpenTelemetry) for microservices

**Rationale**: Observability enables rapid debugging, performance optimization, and proactive issue detection in production.

---

### VI. Schema-First OpenAPI Generation

**OpenAPI specifications MUST be automatically generated from Zod schemas. Manual documentation is forbidden.**

- **Workflow**:
  1. Define Zod schemas for requests/responses in `src/shared/schemas/`
  2. Use schemas in Fastify route validation
  3. Run `npm run gen:openapi` to generate `public/openapi.yaml`
  4. Commit generated OpenAPI to repository
  5. (Optional) Generate TypeScript client types with `npm run gen:client`

- **OpenAPI specification MUST include**:
  - All endpoints with full request/response schemas
  - Error response schemas (400, 404, 500, etc.)
  - Example values for better client DX
  - Authentication/authorization schemes (when implemented)
  - Server URLs for dev/staging/prod environments

- **Validation**:
  - CI pipeline MUST validate generated OpenAPI against OpenAPI 3.x spec
  - Contract tests MUST verify API behavior matches OpenAPI

**Rationale**: Schema-first generation eliminates documentation drift, enables automatic client generation, and ensures contracts are always accurate.

---

### VII. Fastify Patterns & Plugin Architecture

**Leverage Fastify's plugin system, hooks, and decorators. Don't fight the framework.**

- **Plugin-based organization**:
  - Each feature can be a Fastify plugin (encapsulation boundary)
  - Use `fastify-plugin` for utilities that need to share context
  - Register plugins in logical order in `src/app.ts`

- **Plugin example**:

  ```typescript
  // src/plugins/ships.ts
  export default async function shipsPlugin(fastify: FastifyInstance) {
    // Plugin-scoped setup
    fastify.decorate("shipService", createShipService(fastify.db));

    // Routes
    fastify.post("/ships", {schema: {body: createShipSchema}}, createShipHandler);

    fastify.get("/ships", listShipsHandler);
  }
  ```

- **Use Fastify hooks effectively**:
  - `onRequest` — Authentication, logging request start
  - `preValidation` — Custom validation logic
  - `preHandler` — Business logic checks before handler
  - `onSend` — Transform response, add headers
  - `onError` — Centralized error handling

- **Leverage Fastify decorators**:
  - `fastify.decorate()` — Add utilities to Fastify instance (logger, db connection, services)
  - `request.decorate()` — Add request-specific context (user, tenant)
  - Keep decorators typed with TypeScript declaration merging

- **Schema composition**:
  - Share common schemas across routes
  - Use Zod's `.merge()`, `.extend()`, `.pick()` for schema reuse
  - Define reusable error response schemas

- **Avoid over-abstraction**:
  - NO need for elaborate controller/service layers if plugin organization is clear
  - Route handlers can call domain functions directly
  - Only extract services when shared across multiple routes

**Rationale**: Fastify's architecture is built for simplicity and performance. Use its patterns instead of importing heavy enterprise patterns from other ecosystems.

---

## Technology Stack Requirements

### Core Stack (Mandatory)

- **Runtime**: Node.js ≥ v22.18
- **Language**: TypeScript with strict mode enabled (`tsconfig.json`: `strict: true`)
- **Web Framework**: Fastify (preferred for performance and schema-first validation)
- **Database**: PostgreSQL with native migrations (SQL files in `db/migrations/`)
- **Schema Validation**: Zod for runtime validation and TypeScript type inference
- **Logging**: Pino structured JSON logging
- **Testing**: Node.js built-in test runner or Vitest for unit/integration tests
- **OpenAPI**: `@fastify/swagger` + `@fastify/swagger-ui` or `zod-to-openapi`

### Future Stack (Planned)

- **Containerization**: Docker + Docker Compose (`infra/docker/`)
- **Metrics**: TIG stack (Telegraf, InfluxDB, Grafana) configuration in `infra/metrics/`
- **CI/CD**: GitHub Actions for build, test, lint, OpenAPI generation
- **Tracing**: OpenTelemetry (when scaling to distributed services)

### Database Access

- **ORM**: None. Use native PostgreSQL client (`node-postgres` / `pg`) or lightweight query builder (Kysely)
- **Migrations**: Plain SQL files in `db/migrations/` with sequential numbering
- **Connection Pooling**: Configured in `src/infrastructure/database/connection.ts`

### Environment Configuration

- **Environment Variables**: Use `.env` for local dev (not committed)
- **Config Validation**: Validate environment with Zod schema on startup
- `.env.example` MUST document all required variables:
  - `DATABASE_URL`, `LOG_LEVEL`, `PORT`, `NODE_ENV`, `METRICS_ENABLED`, etc.

---

## Development Workflow

### Project Structure (Pragmatic Node.js/Fastify)

```
marine-traffic/
├── docs/                    # Developer documentation, architecture diagrams
├── db/                      # SQL migration files
│   └── migrations/
│       └── 001_initial.sql
├── public/                  # Generated OpenAPI spec
│   └── openapi.yaml
├── scripts/                 # Setup scripts (.sh files)
│   ├── setup-hooks.sh
│   └── gen-openapi.sh
├── src/                     # Application source code
│   ├── domain/              # Business logic (pure functions/classes, no HTTP)
│   │   └── ships/
│   │       ├── collision-detector.ts
│   │       ├── position-tracker.ts
│   │       └── ship.ts (entity if needed)
│   ├── routes/              # Fastify route handlers
│   │   └── ships.ts
│   ├── plugins/             # Fastify plugins (feature modules)
│   │   ├── database.ts
│   │   ├── swagger.ts
│   │   └── ships.ts
│   ├── schemas/             # Zod schemas for validation & OpenAPI
│   │   └── ships.schema.ts
│   ├── lib/                 # Utilities, database queries, helpers
│   │   ├── db.ts
│   │   ├── logger.ts
│   │   └── errors.ts
│   ├── app.ts               # Fastify app setup & plugin registration
│   └── server.ts            # Server bootstrap
├── infra/                   # Infrastructure configuration
│   ├── docker/
│   ├── metrics/             # TIG stack config
│   └── logging/
├── tests/                   # Tests (unit, integration, contract)
│   ├── unit/
│   │   └── domain/          # Test pure business logic
│   ├── integration/         # Test with database
│   └── contract/            # Test API contracts
├── .env.example
├── package.json
├── tsconfig.json
└── README.md
```

### Code Review Requirements

- **All PRs MUST pass**:
  - `npm run typecheck` — TypeScript strict mode, zero errors
  - `npm run lint` — ESLint with zero violations
  - `npm run test` — All tests passing, coverage targets met
  - `npm run gen:openapi` — OpenAPI generation succeeds

- **Constitution compliance checklist** in PR template:
  - [ ] Business logic in `src/domain/`, no Fastify/HTTP dependencies
  - [ ] Tests written before implementation (TDD)
  - [ ] Zod schemas defined for new API contracts
  - [ ] OpenAPI regenerated if API changed
  - [ ] Structured logging with Pino
  - [ ] HTTP status codes used correctly
  - [ ] Fastify patterns used appropriately (plugins, hooks, decorators)

### Git Workflow

- **Feature branches**: `###-feature-name` (e.g., `BTS-123-collision-detection`)
- **Commit messages**: Conventional Commits format (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`)
- **Pre-commit hooks** (in `scripts/`): Lint and typecheck
- **Pre-push hooks**: Run tests

---

## Governance

### Amendment Process

- Constitution changes require:
  1. Written proposal with rationale
  2. Team discussion and approval
  3. Update to this document with version bump
  4. Migration plan if existing code affected

### Version Bump Rules

- **MAJOR** (X.0.0): Breaking changes to core principles (e.g., removing DDD layers, changing test requirements)
- **MINOR** (x.Y.0): New principles added, materially expanded guidance
- **PATCH** (x.y.Z): Clarifications, typos, non-semantic refinements

### Compliance

- Constitution supersedes all other documentation and practices
- All PRs MUST verify compliance (see Code Review Requirements above)
- Complexity exceptions MUST be justified in writing (e.g., "Why we need X pattern despite simplicity principle")
- For runtime development guidance, refer to `docs/DEVELOPER_TOOLS.md` and this constitution

### Retrospectives

- Review constitution alignment quarterly
- Update constitution if principles proven insufficient or overly restrictive
- Document lessons learned in `docs/ARCHITECTURE_DECISIONS.md`

---

**Version**: 1.0.0 | **Ratified**: 2025-10-20 | **Last Amended**: 2025-10-20
