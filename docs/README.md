# Documentation Guide

이 디렉터리는 `domodachi` 프로젝트 문서를 역할별로 나눠 관리합니다.

## 먼저 읽을 문서

1. [Getting Started](./getting-started.md)
2. [Architecture Overview](./architecture/overview.md)
3. [Testing Guide](./testing.md)
4. [Supabase Overview](./supabase/overview.md)
5. [Product Planning](./planning/README.md)

## 언제 어떤 문서를 수정할지

- 로컬 실행 절차, 환경 변수, codegen 흐름이 바뀌면 [getting-started.md](./getting-started.md)를 수정합니다.
- 레이어 규칙, DI 방식, 라우팅 정책, 상태관리 원칙이 바뀌면 [architecture/overview.md](./architecture/overview.md)를 수정합니다.
- 테스트 기준, 테스트 명령, 레이어별 테스트 전략이 바뀌면 [testing.md](./testing.md)를 수정합니다.
- 테이블, RPC, migration 운영 방식, 앱과 Supabase의 책임 분리가 바뀌면 [supabase/overview.md](./supabase/overview.md)를 수정합니다.
- 제품 방향, 익명성 정책, 사용자 흐름, 로드맵이 바뀌면 [planning/README.md](./planning/README.md)와 하위 기획 문서를 수정합니다.
- 특정 도메인 기능의 세부 흐름이 바뀌면 feature README를 수정합니다.

## Feature 문서

- [Auth Feature](../apps/mobile/lib/features/auth/README.md)
- [Chat Feature](../apps/mobile/lib/features/chat/README.md)
- [Friend Feature](../apps/mobile/lib/features/friend/README.md)

## 기획 문서

- [Product Planning](./planning/README.md)
- [Product Overview](./planning/product-overview.md)
- [Identity Policy](./planning/identity-policy.md)
- [User Flows](./planning/user-flows.md)
- [Roadmap](./planning/roadmap.md)

## 문서 작성 원칙

- 루트 `README`는 입문용으로 짧게 유지합니다.
- 설계 배경보다 현재 동작과 규칙을 먼저 적습니다.
- 추상 설명만 두지 말고 관련 코드 경로를 함께 링크합니다.
- 중복 설명이 생기면 루트 문서에는 요약만 남기고 상세는 하위 문서로 이동합니다.
