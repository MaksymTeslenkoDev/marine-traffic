# Ship Coordination Dispatch Service

A maritime traffic management system designed to prevent ship collisions in open waters through real-time position tracking and collision detection algorithms.

## 🚢 Project Overview

The Ship Coordination Dispatch Service is responsible for ensuring the safety of maritime traffic in open waters. The system calculates potential collisions between ships registered in the dispatch service by tracking their positions and trajectories in real-time.

### What Problem Does This Solve?

Maritime accidents, particularly ship collisions, pose significant risks to:

- **Human Safety**: Crew members and passengers aboard vessels
- **Environmental Protection**: Preventing oil spills and maritime pollution
- **Economic Impact**: Avoiding vessel damage and cargo loss
- **Navigation Efficiency**: Optimizing safe routes in congested waters

This service provides a centralized coordination system where ships can transmit their positions via an open API, enabling proactive collision detection and prevention through automated alerts and real-time monitoring.

## 🎯 Key Features

- **Real-time Position Tracking**: Ships transmit ID and coordinates via open API
- **Collision Detection**: Automated algorithms calculate potential collision risks
- **Open API**: Any registered ship can submit position data
- **Scalable Architecture**: Designed to handle multiple vessels simultaneously

## 🛠️ Tech Stack

- **Runtime**: Node.js (v22.18+)
- **Language**: TypeScript
- **Web Framework**: Fastify
- **Configuration**: JSON Schema validation with @sinclair/typebox
- **Logging**: Pino (structured logging)
- **Testing**: Node.js test runner / Tap
- **Containerization**: Docker & Docker Compose

## 📁 Project Structure

```
ship-dispatch-service/
├── src/                    # Application source code
├── infra/                  # Infrastructure configurations (Docker, monitoring)
├── docs/                   # Project documentation
├── app.config.json         # Application configuration
└── README.md              # This file
```

_Detailed structure will be updated as the project develops._

## 🚀 Getting Started

> **Note**: This section will be filled with detailed setup instructions as the project progresses.

Coming soon:

- Installation requirements
- Local development setup
- Running the application
- Running tests
- API documentation

## 📊 Project Management

This project follows a complete Software Development Life Cycle (SDLC) approach with:

- Sprint planning and tracking
- Jira board for task management
- Git workflow with feature branches
- Code reviews and quality gates

**Jira Board**: https://maksimteslenkodev.atlassian.net/jira/software/projects/BTS/boards/1

## 📖 Development Philosophy

This project is developed as a comprehensive demonstration of:

- Full-stack backend development practices
- Production-ready architecture patterns
- Observability and monitoring from day one
- Test-driven development
- Clean code and documentation standards
- DevOps and CI/CD practices

## 📝 License

Apache 2.0

## 👤 Author

Maksym Teslenko/ https://github.com/MaksymTeslenkoDev

---

## 🛠️ Developer Tools

This project uses ESLint and Prettier for code quality. See the [Developer Tools Guide](docs/DEVELOPER_TOOLS.md) for available commands and setup instructions.

**Status**: 🚧 In Development - EPIC 1: Project Setup & Development Environment
