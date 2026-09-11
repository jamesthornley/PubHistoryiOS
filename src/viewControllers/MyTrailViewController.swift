//
//  MyTrailViewController.swift
//  London
//
//  Created by  James on 26/03/2025.
//  Copyright © 2025 CoDeveloper. All rights reserved.
//

import Foundation

import UIKit

@objcMembers

@objc(MyTrailViewController)
class MyTrailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var myViewheader: UIView!
    @IBOutlet weak var startTrailView: UIView!
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!

    var pub: Pub?
    var noteList: NoteList!
    var appeared = false
    var defaultBottomTextEntry: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        text.layer.borderColor = UIColor.gray.cgColor
        text.layer.borderWidth = 1.0
        text.layer.cornerRadius = 8

        defaultBottomTextEntry = bottomTextEntry.constant

        let tapper = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appeared = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToEnd()
        appeared = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if let parent = self.parent as? PubTabViewController {
            pub = parent.pub
            noteList = NoteList
                .getWithUserID(
                    UserList.getCurrentUser().userID,
                    withPubID: Int(pub?.getNumber() ?? "0") ?? 0
                )
            noteList.sort()
            myViewheader.isHidden = true
            tableTopConstraint.constant = 0
        } else {
            noteList = NoteList
                .getWithUserID(
                    UserList.getCurrentUser().userID,
                    withTrailCode: PHAleTrailFactory.getCurrentPHAleTrail().code
                )
            noteList.sort()
        }

        startTrailView.isHidden = TrailList.onTrail() || NoteList.thereAreNotes()
        mainTable.reloadData()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return noteList.getSections().count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = noteList.getSections() as? [NSArray],
              section < sections.count,
              let notes = sections[section].object(at: 1) as? [Any]
        else {
            return 0
        }
        
        return notes.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = noteList.getSections() as? [NSArray],
              section < sections.count,
              let pub = sections[section].object(at: 0) as? Pub else {
            return "Untitled"
        }
        return pub.getTitle()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SectionHeader") as? SectionHeadingTableViewCell
        if cell == nil {
            cell = SectionHeadingTableViewCell(style: .default, reuseIdentifier: "SectionHeader")
        }
        guard let sections = noteList.getSections() as? [NSArray],
              section < sections.count,
              let pub = sections[section].object(at: 0) as? Pub else {
            return cell
        }
                
                cell?.titleLabel.text = " " + pub.getTitle()
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return pub != nil ? 0 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "NoteListCellLeft"

        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? NotesListCellTableViewCell
        if cell == nil {
            cell = NotesListCellTableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        guard let sections = noteList.getSections() as? [NSArray],
              indexPath.section < sections.count,
              let notes = sections[indexPath.section].object(at: 1) as? [Any],
                let note = notes[0] as? Note
        else {
            return cell!
        }
        

        if note.isCurrentUserWithoutDatabase() {
            identifier = "NoteListCellRight"
        }

        cell?.note = note
        if let parent = self.parent as? PubTabViewController {
            cell?.parent = parent
        } else {
            cell?.parent = self
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sections = noteList.getSections() as? [NSArray],
              indexPath.section < sections.count,
              let notes = sections[indexPath.section].object(at: 1) as? [Any],
                let note = notes[0] as? Note
        else {
            return 0
        }
        return note.getSize().height + 10
    }

    @objc func keyboardWasShown(_ notification: Notification) {
        if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            let movement = kbSize.height
            if movement > 0 && bottomTextEntry.constant == defaultBottomTextEntry {
                bottomTextEntry.constant = movement
                UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
            }
        }
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        bottomTextEntry.constant = defaultBottomTextEntry
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
        let loc = sender.location(in: view)
        if let subview = view.hitTest(loc, with: nil), !(subview is UIButton) {
            view.endEditing(true)
        }
    }

    @IBAction func reload() {
        var shouldScroll = false
        if mainTable != nil, appeared, mainTable.contentOffset.y + 1 >= mainTable.contentSize.height - mainTable.frame.size.height {
            shouldScroll = true
        }

        if pub != nil {
            noteList = NoteList
                .getWithUserID(
                    UserList.getCurrentUser().userID,
                    withPubID: Int(pub!.getNumber())!
                )
        } else {
            noteList = NoteList
                .getWithUserID(
                    UserList.getCurrentUser().userID,
                    withTrailCode: PHAleTrailFactory.getCurrentPHAleTrail().code
                )
        }

        noteList.sort()
        mainTable.reloadData()

        if shouldScroll {
            scrollToEnd()
        }
    }

    func scrollToEnd() {
        guard noteList.size() > 1, noteList.getSections().count > 0 else { return }

            let sections = noteList.getSections() as? [NSArray]
            let notes = sections?.last as? [Note]
        
            let indexPath = IndexPath(
                row: (notes?.count ?? 0) - 1,
                section: noteList.getSections().count - 1
            )
        
            mainTable.scrollToRow(at: indexPath, at: .none, animated: true)
       
    }

    @IBAction func start() {
        tabBarController?.selectedIndex = 4
        if let nav = tabBarController?.viewControllers?[4] as? UINavigationController,
           let cont = nav.viewControllers.first as? MoreViewController {
            cont.start()
        }
    }
}

