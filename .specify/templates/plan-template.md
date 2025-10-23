# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]  
**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]  
**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]  
**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]  
**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]
**Project Type**: [single/web/mobile - determines source structure]  
**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

_GATE: Must pass before Phase 0 research. Re-check after Phase 1 design._

**Domain/Transport Separation (Pragmatic)**:

- [ ] Business logic will reside in `src/domain/` with no Fastify/HTTP dependencies
- [ ] Route handlers in `src/routes/` or Fastify plugins in `src/plugins/`
- [ ] Domain functions are pure and testable without HTTP context
- [ ] Database access kept simple (plain functions, no complex abstractions unless justified)
- [ ] NO unnecessary DTOs or mapping layers

**Type-Safe Contract-First**:

- [ ] Zod schemas defined for all API contracts in `src/schemas/`
- [ ] TypeScript types derived from Zod using `z.infer<>`
- [ ] OpenAPI will be auto-generated from Zod schemas to `public/openapi.yaml`

**Test-Driven Development (TDD)**:

- [ ] Tests will be written BEFORE implementation (Red-Green-Refactor)
- [ ] Coverage targets: Domain ≥90%, Routes ≥80%, Integration ≥70%
- [ ] Unit tests for domain logic, integration tests for database, contract tests for API

**RESTful API Standards**:

- [ ] Resource-based URLs with proper HTTP methods (GET, POST, PUT, PATCH, DELETE)
- [ ] Correct HTTP status codes (200, 201, 204, 400, 404, 409, 422, 500)
- [ ] Pagination for list endpoints (?limit=X&offset=Y)
- [ ] Structured error responses with code, message, and details

**Observability**:

- [ ] Pino structured JSON logging will be used
- [ ] Request correlation IDs for tracing
- [ ] No sensitive data in logs
- [ ] Metrics configuration in `infra/metrics/` (for future TIG stack)

**Fastify Patterns**:

- [ ] Plugin-based organization for feature modules
- [ ] Fastify hooks used appropriately (onRequest, preHandler, onError, etc.)
- [ ] Decorators for shared utilities (db, logger, services)
- [ ] Schema composition with Zod for validation

**Tech Stack Compliance**:

- [ ] Node.js ≥ v22.18
- [ ] TypeScript strict mode enabled
- [ ] Fastify web framework
- [ ] PostgreSQL with SQL migrations in `db/migrations/`
- [ ] Zod for validation
- [ ] Pino for logging

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

_Fill ONLY if Constitution Check has violations that must be justified_

| Violation                  | Why Needed         | Simpler Alternative Rejected Because |
| -------------------------- | ------------------ | ------------------------------------ |
| [e.g., 4th project]        | [current need]     | [why 3 projects insufficient]        |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient]  |
