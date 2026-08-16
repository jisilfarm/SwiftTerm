//
//  AtermAccess.swift
//  aTerm 뷰 계층이 모듈 밖에서 필요로 하는 최소 공개 접근자.
//
//  뷰 계층(렌더링·입력·IME·스크롤)은 aTerm이 소유하므로, SwiftTerm 자신의 뷰가
//  internal로 쓰던 값들을 밖에서 읽을 길이 필요하다. 상류 리베이스가 깨지지 않도록
//  기존 파일은 건드리지 않고 이 파일만 더하며, 심볼에는 aterm 접두사를 붙인다.
//

import Foundation

extension Terminal {
    /// 활성 버퍼가 보유한 전체 행 수 — 스크롤백을 포함한다.
    public var atermTotalLines: Int {
        buffer.lines.count
    }

    /// `buffer.yDisp`가 가질 수 있는 최댓값. 이 값이 곧 스크롤 바닥(최신 출력) 위치다.
    public var atermMaxScrollPosition: Int {
        max(0, buffer.lines.count - rows)
    }

    /// 세션 시작부터 세어 현재 보유 중인 가장 오래된 행의 절대 인덱스.
    /// 스크롤백 한도를 넘겨 버려진 행 수와 같다.
    public var atermScrollbackTopIndex: Int {
        buffer.totalLinesTrimmed
    }

    /// 클라이언트 앱이 커서를 숨기라고 요청한 상태인지.
    public var atermIsCursorHidden: Bool {
        cursorHidden
    }

    /// 지금 표시 중인 뷰포트 기준 커서 행. 스크롤로 커서가 화면 밖에 있으면
    /// 음수이거나 `rows` 이상이 되며, 그때는 커서를 그리지 않는다.
    public var atermCursorViewportRow: Int {
        buffer.yBase + buffer.y - buffer.yDisp
    }
}
