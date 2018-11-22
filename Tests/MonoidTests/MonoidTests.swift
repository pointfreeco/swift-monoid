import XCTest
@testable import Monoid

final class MonoidTests: XCTestCase {

  func testAny() {
    XCTAssertEqual(Semigroup.any.combine(true, true), true)
    XCTAssertEqual(Semigroup.any.combine(false, true), true)
    XCTAssertEqual(Semigroup.any.combine(true, false), true)
    XCTAssertEqual(Semigroup.any.combine(false, false), false)

    XCTAssertEqual(true, Monoid.any.fold([true, true]))
    XCTAssertEqual(true, Monoid.any.fold([false, true]))
    XCTAssertEqual(true, Monoid.any.fold([true, false]))
    XCTAssertEqual(false, Monoid.any.fold([false, false]))

    XCTAssertEqual(false, Monoid.any.fold([]))
  }

  func testAll() {
    XCTAssertEqual(Semigroup.all.combine(true, true), true)
    XCTAssertEqual(Semigroup.all.combine(false, true), false)
    XCTAssertEqual(Semigroup.all.combine(true, false), false)
    XCTAssertEqual(Semigroup.all.combine(false, false), false)

    XCTAssertEqual(true, Monoid.all.fold([true, true]))
    XCTAssertEqual(false, Monoid.all.fold([false, true]))
    XCTAssertEqual(false, Monoid.all.fold([true, false]))
    XCTAssertEqual(false, Monoid.all.fold([false, false]))

    XCTAssertEqual(true, Monoid.all.fold([]))
  }

  func testMax() {
    XCTAssertEqual(2, Semigroup.max.combine(1, 2))
    XCTAssertEqual(2, Semigroup.max.combine(2, 1))

    XCTAssertEqual(2, Monoid.max.fold([1, 2]))
    XCTAssertEqual(2, Monoid.max.fold([2, 1]))

    XCTAssertEqual(Int.min, Monoid.max.fold([]))
    XCTAssertEqual(UInt.min, Monoid.max.fold([]))
    XCTAssertEqual(-Double.greatestFiniteMagnitude, Monoid.max.fold([]))
    XCTAssertEqual(-Float.greatestFiniteMagnitude, Monoid.max.fold([]))
  }

  func testMin() {
    XCTAssertEqual(1, Semigroup.min.combine(1, 2))
    XCTAssertEqual(1, Semigroup.min.combine(2, 1))

    XCTAssertEqual(1, Monoid.min.fold([1, 2]))
    XCTAssertEqual(1, Monoid.min.fold([2, 1]))

    XCTAssertEqual(Int.max, Monoid.min.fold([]))
    XCTAssertEqual(UInt.max, Monoid.min.fold([]))
    XCTAssertEqual(Double.greatestFiniteMagnitude, Monoid.min.fold([]))
    XCTAssertEqual(Float.greatestFiniteMagnitude, Monoid.min.fold([]))
  }

  func testMerge() {
    XCTAssertEqual(
      [1: "oneuno", 2: "twodos"],
      Semigroup.merge(with: .array).combine([1: "one", 2: "two"], [1: "uno", 2: "dos"])
    )

    XCTAssertEqual(
      [1: "oneuno", 2: "twodos"],
      Monoid.merge(with: .array).fold([[1: "one", 2: "two"], [1: "uno", 2: "dos"]])
    )

    XCTAssertEqual([Int: String](), Monoid.merge(with: .array).fold([]))
  }

  func testEnd() {
    let f: (Int) -> Int = Semigroup.endo.combine({ $0 + 1 }, { $0 * $0})
    let g: (Int) -> Int = Monoid.endo.fold([{ $0 + 1 }, { $0 * $0}])
    let h: (Int) -> Int = Monoid.endo.fold([])

    XCTAssertEqual(1, f(0))
    XCTAssertEqual(4, f(1))
    XCTAssertEqual(9, f(2))

    XCTAssertEqual(1, g(0))
    XCTAssertEqual(4, g(1))
    XCTAssertEqual(9, g(2))

    XCTAssertEqual(0, h(0))
    XCTAssertEqual(1, h(1))
    XCTAssertEqual(2, h(2))
  }

  func testSum() {
    XCTAssertEqual(5, Semigroup.sum.combine(2, 3))
    XCTAssertEqual(5.0, Semigroup.sum.combine(2.0, 3))
  }

  func testProduct() {
    XCTAssertEqual(6, Semigroup.product.combine(2, 3))
    XCTAssertEqual(6.0, Semigroup.product.combine(2.0, 3))
  }

  func testLast() {
    XCTAssertEqual(.some(1), Semigroup.last.combine(nil, 1))
    XCTAssertEqual(.some(1), Semigroup.last.combine(1, nil))
    XCTAssertEqual(.some(2), Semigroup.last.combine(1, 2))

    XCTAssertEqual(.some(1), Monoid.last.fold([nil, 1]))
    XCTAssertEqual(.some(1), Monoid.last.fold([1, nil]))
    XCTAssertEqual(.some(1), Monoid.last.fold([2, 1]))
  }

  func testFirst() {
    XCTAssertEqual(.some(1), Semigroup.first.combine(nil, 1))
    XCTAssertEqual(.some(1), Semigroup.first.combine(1, nil))
    XCTAssertEqual(.some(1), Semigroup.first.combine(1, 2))

    XCTAssertEqual(.some(1), Monoid.first.fold([nil, 1]))
    XCTAssertEqual(.some(1), Monoid.first.fold([1, nil]))
    XCTAssertEqual(.some(2), Monoid.first.fold([2, 1]))
  }

  func testPointwise() {
    let f: (Int) -> [String] = Semigroup.pointwise(into: .array)
      .combine({ ["\($0)", "\($0)"] }, { ["\($0)", "\($0)", "\($0)"] })
    let g: (Int) -> [String] = Monoid.pointwise(into: .array)
      .fold([{ ["\($0)", "\($0)"] }, { ["\($0)", "\($0)", "\($0)"] }])
    let h: (Int) -> [String] = Monoid.pointwise(into: .array).fold([])

    XCTAssertEqual(["1", "1", "1", "1", "1"], f(1))
    XCTAssertEqual(["1", "1", "1", "1", "1"], g(1))
    XCTAssertEqual([], h(1))
  }

  func testTuple() {
    XCTAssertEqual((3, "HelloWorld"), tuple2(.sum, .array).combine((1, "Hello"), (2, "World")))
    XCTAssertEqual((3, "HelloWorld"), tuple2(.sum, .array).fold([(1, "Hello"), (2, "World")]))
  }

  func testAverage() {
    XCTAssertEqual(Average(value: 3), Semigroup.average.combine(Average(value: 2.0), Average(value: 4.0)))
  }

  static var allTests = [
    ("testAny", testAny)
  ]
}

private func XCTAssertEqual<A: Equatable, B: Equatable>(_ expression1: @autoclosure () throws -> (A, B), _ expression2: @autoclosure () throws -> (A, B), file: StaticString = #file, line: UInt = #line) {
  try XCTAssert(expression1() == expression2(), file: file, line: line)
}
