---
name: implementation-toolkit
description: "Router for technology-specific implementation guidance organized by domain. Use when working with Supabase (auth, RLS, edge functions, database), Stripe (payments, subscriptions, webhooks, checkout), Expo (React Native, mobile development, EAS builds), iOS (SwiftUI, UIKit, native Apple development), iOS Simulator (testing, screenshots, automation), caching strategies (Redis, CDN, memoization, component caching), LangChain (agents, chains, RAG, vector stores, LLM orchestration), Docker (containers, compose, images, Dockerfile), or deployment (CI/CD, hosting, infrastructure, cloud providers)."
---

# Implementation Toolkit Router

Read the appropriate guide based on detected technology:

## Frontend

| Technology | Action |
|------------|--------|
| Expo (React Native, EAS, mobile builds) | Read `~/.claude/skills/implementation-toolkit/frontend/expo/GUIDE.md` |
| iOS native (SwiftUI, UIKit, Xcode, Apple APIs) | Read `~/.claude/skills/implementation-toolkit/frontend/ios/GUIDE.md` |
| Caching (Redis, CDN, memoization, component cache) | Read `~/.claude/skills/implementation-toolkit/frontend/cache-components/GUIDE.md` |

## Backend

| Technology | Action |
|------------|--------|
| Supabase (auth, RLS, edge functions, DB, storage) | Read `~/.claude/skills/implementation-toolkit/backend/supabase/GUIDE.md` |
| Stripe (payments, subscriptions, webhooks, checkout) | Read `~/.claude/skills/implementation-toolkit/backend/stripe/GUIDE.md` |
| LangChain (agents, chains, RAG, vector stores) | Read `~/.claude/skills/implementation-toolkit/backend/langchain-architecture/GUIDE.md` |
| Docker (containers, compose, Dockerfile, images) | Read `~/.claude/skills/implementation-toolkit/backend/docker-patterns/GUIDE.md` |
| Deployment (CI/CD, hosting, cloud, infrastructure) | Read `~/.claude/skills/implementation-toolkit/backend/deployment-patterns/GUIDE.md` |

## Testing

| Technology | Action |
|------------|--------|
| iOS Simulator (testing, screenshots, automation) | Read `~/.claude/skills/implementation-toolkit/testing/ios-simulator-skill/GUIDE.md` |

## UI/UX

<!-- Add UI/UX-specific implementation tools here -->

## Coding Language

<!-- Add language-specific guides here (e.g., TypeScript patterns, Swift idioms, Python best practices) -->

Load multiple guides when the task involves several technologies.
