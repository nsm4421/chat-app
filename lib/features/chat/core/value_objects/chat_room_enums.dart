enum ChatRoomType { private, group }

/// Chat room lifecycle/availability status.
///
/// - `draft`: 게시 전 임시 상태로, 호스트만 볼 수 있으며 참여할 수 없습니다.
/// - `open`: 활성 상태이며 참여할 수 있습니다.
/// - `full`: 활성 상태이지만 정원이 차서 더 이상 참여할 수 없습니다.
/// - `closed`: 호스트 또는 관리자가 명시적으로 종료한 비활성 상태입니다.
enum ChatRoomStatus { draft, open, full, closed }
