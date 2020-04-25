//
//  TagDataSource.swift
//  Photorama
//
//  Created by Vladislav Tarasevich on 25.04.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit
import CoreData

final class TagDataSource: NSObject, UITableViewDataSource {

    // MARK: - Properties

    var tags = [Tag]()

    // MARK: - Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)

        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag.name

        return cell
    }

}
