import WidgetKit
import SwiftUI

@main
struct CloudStudyWidgetBundle: WidgetBundle {
    var body: some Widget {
        CloudStudyMainWidget()
        CloudStudyLockCircular()
        CloudStudyLockRectangular()
        CloudStudyLockInline()
        CloudStudyLiveActivity()
    }
}
