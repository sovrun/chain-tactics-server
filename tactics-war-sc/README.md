# Tactics War SC

Welcome to the Tactics War SC repository. This project is built using MUD, a versatile framework for developing blockchain-based games.

## Table of Contents

- [Tactics War SC](#tactics-war-sc)
  - [Table of Contents](#table-of-contents)
  - [Getting Started](#getting-started)
  - [System Documentation](#system-documentation)
  - [Table Documentation](#table-documentation)
  - [Generating C# Files for Unity](#generating-c-files-for-unity)

## Getting Started

To get started with the project, follow these steps:

1. [Prerequisites](./docs/Prerequisites.md)
2. [Setup Guide](./docs/Setup.md)
3. [Deployment Guide](./docs/Deployment.md)

## System Documentation

Explore the documentation for different systems in the Tactics War SC:

- [MatchSystem](./docs/system/MatchSystem.md)
- [BuySystem](./docs/system/BuySystem.md)
- [SpawnSystem](./docs/system/SpawnSystem.md)
- [CombatSystem](./docs/system/CombatSystem.md)
- [MoveSystem](./docs/system/MoveSystem.md)
- [TurnSystem](./docs/system/TurnSystem.md)

## Table Documentation

Learn about the ECS (Entity-Component-System) MUD tables used in Tactics War:

- [MatchSystem Tables](./docs/tables/MatchSystem.md)
- [BuySystem Tables](./docs/tables/BuySystem.md)
- [SpawnSystem Tables](./docs/tables/SpawnSystem.md)
- [CombatSystem Tables](./docs/tables/CombatSystem.md)
- [MoveSystem Tables](./docs/tables/MoveSystem.md)
- [TurnSystem Tables](./docs/tables/TurnSystem.md)

## Generating C# Files for Unity

To generate the necessary C# files for the Unity game, follow these steps:

1. Navigate to the `packages/contracts` directory:
   ```sh
   cd packages/contracts
   ```
2. Run the following command:
   ```sh
   pnpm dev:unity
   ```

This command will generate the tables needed for the Unity game.
