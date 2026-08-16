//
//  AtermAccess.swift
//  aTerm 뷰 계층이 모듈 밖에서 필요로 하는 최소 공개 접근자.
//
//  뷰 계층(렌더링·입력·IME·스크롤)은 aTerm이 소유하므로, SwiftTerm 자신의 뷰가
//  internal로 쓰던 값들을 밖에서 읽을 길이 필요하다. 상류 리베이스가 깨지지 않도록
//  기존 파일은 건드리지 않고 이 파일만 더하며, 심볼에는 aterm 접두사를 붙인다.
//
//  축은 둘이다 — **history**(스크롤백을 쥔 일반 버퍼)와 **screen**(눈앞의 활성 버퍼).
//  스크롤 위치(`yDisp`)에 매인 값은 하나도 두지 않는다. 대안 화면에서는 뜻을 잃고,
//  M2에서 세션 원본이 서버로 넘어가면 클라이언트가 만질 수 없는 값이기 때문이다.
//

import Foundation

extension Terminal {
    /// 스크롤백을 보유한 일반 버퍼의 전체 행 수.
    ///
    /// 대안 화면(vim·less·claude)이 떠 있는 동안에도 이 값과 내용은 얼어붙은 채
    /// 남는다 — C1.3의 "vim을 띄운 채 이전 셸 출력을 되짚는다"가 서는 근거다.
    public var atermHistoryLineCount: Int {
        normalBuffer.lines.count
    }

    /// 일반 버퍼의 `index`번째 행. 0이 보유 중 가장 오래된 행이다.
    public func atermHistoryLine(at index: Int) -> BufferLine? {
        guard index >= 0, index < normalBuffer.lines.count else { return nil }
        return normalBuffer.lines[index]
    }

    /// 지금 활성 버퍼의 화면 `row`행.
    ///
    /// 스크롤 위치와 무관하게 언제나 "살아 있는 화면"을 준다. 대안 화면이 떠 있으면
    /// 그 화면이고, 아니면 일반 버퍼의 마지막 `rows`행이다.
    public func atermScreenLine(row: Int) -> BufferLine? {
        guard row >= 0, row < rows else { return nil }
        let index = buffer.yBase + row
        guard index >= 0, index < buffer.lines.count else { return nil }
        return buffer.lines[index]
    }

    /// 스크롤백 한도를 넘겨 버려진 행 수. 세션 시작부터 누적된다.
    public var atermTrimmedLineCount: Int {
        normalBuffer.totalLinesTrimmed
    }

    /// 클라이언트 앱이 커서를 숨기라고 요청한 상태인지.
    public var atermIsCursorHidden: Bool {
        cursorHidden
    }

    /// 이 스칼라가 화면에서 차지하는 칸 수. 전각이면 2, 결합 문자는 0이다.
    ///
    /// 에뮬레이터가 버퍼를 채울 때 쓰는 것과 **같은 표**다. 조합 중인 글자는 아직
    /// 버퍼에 없어 `CharData.width`를 물을 수 없는데, 렌더러가 표를 따로 들면
    /// 전각 경계가 어긋난다(C4.1·C4.5).
    public static func atermColumnWidth(of scalar: UnicodeScalar) -> Int {
        UnicodeUtil.columnWidth(rune: scalar)
    }

    /// 글자 하나의 칸 수. 결합 문자가 붙어 있으면 첫 스칼라의 폭을 따른다.
    public static func atermColumnWidth(of character: Character) -> Int {
        guard let first = character.unicodeScalars.first else { return 0 }
        return max(0, atermColumnWidth(of: first))
    }
}
