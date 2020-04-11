//
//  DrawView.swift
//  TouchTracker
//
//  Created by Vladislav Tarasevich on 31.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit

final class DrawView: UIView, UIGestureRecognizerDelegate {

    // MARK: - Types

    enum DrawingMode {
        case line
        case circle
    }

    // MARK: - Overrides

    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - Private properties

    private var drawingMode: DrawingMode = .line

    private var currentLines = [NSValue: Line]()
    private var finishedLines = [Line]()

    private var currentTouches = [NSValue: CGPoint]()
    private var currentCircles = [NSValue: Circle]()
    private var finishedCircles = [Circle]()

    private var selectedLineIndex: Int? {
        didSet {
            if selectedLineIndex == nil {
                UIMenuController.shared.hideMenu(from: self)
            }
        }
    }

    private var moveGestureRecognizer = UIPanGestureRecognizer()

    // MARK: - Init

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        moveGestureRecognizer.delegate = self

        configureGestures()
    }

    // MARK: - Methods

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Private action methods

    @IBAction private func changeDrawingType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            drawingMode = .line

        case 1:
            drawingMode = .circle

        default:
            log(error: "Unknown sender segemnt index \(sender.selectedSegmentIndex)")
        }
    }

    // MARK: - Overrides

    override func draw(_ rect: CGRect) {
        for line in finishedLines {
            drawStroke(line, color: line.color)
        }

        for circle in finishedCircles {
            drawCircle(circle)
        }

        for (_, line) in currentLines {
            drawStroke(line, color: line.color)
        }

        for (_, circle) in currentCircles {
            drawCircle(circle)
        }

        if let index = selectedLineIndex {
            let selectedLine = finishedLines[index]
            drawStroke(selectedLine, color: UIColor.green)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard selectedLineIndex == nil else {
            return
        }

        for touch in touches {
            let location = touch.location(in: self)
            let key = NSValue(nonretainedObject: touch)
            currentTouches[key] = touch.location(in: self)

            switch drawingMode {
            case .circle:
                touchesBeganForCircle(with: location, with: key)

            case .line:
                currentLines[key] = Line(start: location, end: location)
            }
        }
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let key = NSValue(nonretainedObject: touch)
            currentTouches[key] = location

            switch drawingMode {
            case .circle:
                touchesMovedForCircle(with: location, with: key)

            case .line:
                currentLines[key]?.end = location

                let velocity = moveGestureRecognizer.velocity(in: self)
                let normalizedVelocity = (round(hypot(velocity.x, velocity.y)) / 20).truncatingRemainder(dividingBy: 40)
                if let thickness = currentLines[key]?.thickness, normalizedVelocity > thickness {
                    currentLines[key]?.thickness = normalizedVelocity
                }
            }
        }
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let key = NSValue(nonretainedObject: touch)
            currentTouches[key] = location

            switch drawingMode {
            case .circle:
                guard let circle = currentCircles[key] else {
                    log(error: "Unable to find circle for key <\(key)>")
                    return
                }
                touchesMovedForCircle(with: location, with: key)
                finishedCircles.append(circle)
                currentCircles.removeValue(forKey: key)

            case .line:
                guard let line = currentLines[key] else {
                    continue
                }
                currentLines[key]?.end = location
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
            }
            currentTouches.removeValue(forKey: key)
        }
        setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentLines.removeAll()
        setNeedsDisplay()
    }

    // MARK: - Private methods

    // MARK: - UI

    private func drawStroke(_ line: Line, color: UIColor) {
        color.setStroke()
        let path = UIBezierPath()
        path.lineWidth = line.thickness
        path.lineCapStyle = .round

        path.move(to: line.start)
        path.addLine(to: line.end)
        path.stroke()
    }

    private func drawCircle(_ circle: Circle) {
        let path = UIBezierPath(arcCenter: circle.center,
                                radius: circle.radius,
                                startAngle: CGFloat(0),
                                endAngle: 2 * CGFloat.pi,
                                clockwise: true)
        UIColor.red.setStroke()
        UIColor.red.setFill()
        path.stroke()
    }

    @objc
    private func deleteLine(_ sender: UIMenuController) {
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil

            setNeedsDisplay()
        }
    }

    // MARK: - Touches

    private func touchesBeganForCircle(with touchLocation: CGPoint, with touchKey: NSValue) {
        if currentTouches.count % 2 == 1 {
            currentCircles[touchKey] = Circle(center: touchLocation, radius: 100)
        } else {
            guard let firstTouchKey = getSingleTouchKey(from: currentCircles),
                  let firstTouchLocation = currentTouches[firstTouchKey],
                  var circle = currentCircles[firstTouchKey] else {
                log(error: "Some of key values are nil for <\(currentCircles)>")
                return
            }

            circle.updateWith(firstTouchLocation: firstTouchLocation, secondTouchLocation: touchLocation)
            currentCircles[firstTouchKey] = circle
            currentCircles[touchKey] = circle
        }
    }

    private func touchesMovedForCircle(with touchLocation: CGPoint, with touchKey: NSValue) {
        guard var circle = currentCircles[touchKey] else {
            log(error: "Unable to find circle for key <\(touchKey)>")
            return
        }

        let keysForCircle = getCurrentKeys(for: circle)
        switch keysForCircle.count {
        case 1:
            currentCircles[touchKey]?.center = touchLocation

        case 2:
            guard let firstTouchKey = keysForCircle.first,
                  let secondTouchKey = keysForCircle.last,
                  let firstLocation = currentTouches[firstTouchKey],
                  let secondLocation = currentTouches[secondTouchKey] else {
                log(error: "Some of key values are nil for <\(keysForCircle)>")
                return
            }
            circle.updateWith(firstTouchLocation: firstLocation, secondTouchLocation: secondLocation)
            currentCircles[firstTouchKey] = circle
            currentCircles[secondTouchKey] = circle

        default:
            log(error: "The number of touches for one circle should be either 1 or 2. Got \(keysForCircle.count)")
        }
    }

    private func getSingleTouchKey(from circles: [NSValue: Circle]) -> NSValue? {
        return circles.filter { _, circle in
            getCurrentKeys(for: circle).count == 1
        }.first?.key
    }

    private func getCurrentKeys(for circle: Circle) -> [NSValue] {
        return currentCircles.keys.filter { currentCircles[$0] == circle }
    }

    // MARK: - Gestures

    private func configureGestures() {
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)

        moveGestureRecognizer.addTarget(self, action: #selector(DrawView.moveLine(_:)))
        moveGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveGestureRecognizer)
    }

    @objc
    private func doubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        log(info: "Recognized a double tap")

        selectedLineIndex = nil
        currentTouches.removeAll()

        currentLines.removeAll()
        finishedLines.removeAll()
        currentCircles.removeAll()
        finishedCircles.removeAll()

        setNeedsDisplay()
    }

    @objc
    private func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        log(info: "Recognized a tap")

        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)

        let menu = UIMenuController.shared

        if selectedLineIndex != nil {
            becomeFirstResponder()
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
            menu.menuItems = [deleteItem]

            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.showMenu(from: self, rect: targetRect)
        } else {
            menu.hideMenu(from: self)
        }

        setNeedsDisplay()
    }

    @objc
    private func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLine(at: point)

            if selectedLineIndex != nil {
                currentLines.removeAll()
            }

        case .ended:
            selectedLineIndex = nil

        default:
            break
        }

        setNeedsDisplay()
    }

    @objc
    private func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        if let index = selectedLineIndex, gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self)
            finishedLines[index].start.x += translation.x
            finishedLines[index].start.y += translation.y
            finishedLines[index].end.x += translation.x
            finishedLines[index].end.y += translation.y
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
            setNeedsDisplay()
        }
    }

    private func indexOfLine(at point: CGPoint) -> Int? {
        for (index, line) in finishedLines.enumerated() {
            let begin = line.start
            let end = line.end

            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)

                if hypot(x - point.x, y - point.y) < 20 {
                    return index
                }
            }
        }
        return nil
    }

}
