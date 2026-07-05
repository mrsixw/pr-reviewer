# Curated test frameworks & helpers

Mature, well-rated libraries that take on the heavy lifting so tests stay
clean with minimal hand-crafted mocks. Recommend from this list first; only
search the web when the stack in the diff isn't covered here (or this file
looks out of date for it).

## Python

| Need | Use |
|---|---|
| Test runner | `pytest` (fixtures, parametrize — not unittest boilerplate) |
| AWS services | `moto` |
| HTTP APIs (requests/httpx) | `responses`, `requests-mock`, `respx` (httpx) |
| Time/dates | `freezegun` (or `time-machine` for speed) |
| Fake data | `faker`, `factory_boy` |
| Property-based | `hypothesis` |
| Real services in containers | `testcontainers-python` |
| Coverage | `pytest-cov` |

## JavaScript / TypeScript

| Need | Use |
|---|---|
| Test runner | `vitest` (new projects) or `jest` (established ones) |
| HTTP mocking | `msw` (mock service worker), `nock` (node) |
| DOM/component testing | `@testing-library/*` |
| E2E browser | `playwright` |
| Time | built-in fake timers (`vi.useFakeTimers` / `jest.useFakeTimers`) |

## Java / JVM

| Need | Use |
|---|---|
| Test runner | JUnit 5 |
| Mocking | Mockito |
| Assertions | AssertJ |
| HTTP mocking | WireMock |
| Real services in containers | Testcontainers |
| Time | `java.time.Clock` injection (test with `Clock.fixed`) |

## Go

| Need | Use |
|---|---|
| Assertions/mocks | `testify` |
| HTTP | `net/http/httptest` (stdlib — prefer it) |
| Real services in containers | `testcontainers-go` |
| Table-driven tests | idiomatic stdlib pattern, no library needed |

## Ruby

| Need | Use |
|---|---|
| Test runner | RSpec (or minitest if the repo already uses it) |
| HTTP mocking | `webmock`, `vcr` |
| Time | `timecop` (or Rails' `travel_to`) |
| Fake data | `faker`, `factory_bot` |

## Rust

| Need | Use |
|---|---|
| Test runner | built-in `#[test]` / `cargo test` |
| HTTP mocking | `wiremock` (async) or `mockito` crate |
| Property-based | `proptest` |
| Snapshots | `insta` |

## Shell

| Need | Use |
|---|---|
| Test runner | `bats-core` |
| Linting as testing | `shellcheck` in CI |
