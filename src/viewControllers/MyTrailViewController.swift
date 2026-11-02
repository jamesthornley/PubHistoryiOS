//
//  MyTrailViewController.swift
//  London
//
//  Created by  James on 26/03/2025.
//  Copyright © 2025 CoDeveloper. All rights reserved.
//

import UIKit

@objcMembers
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
        let userID = UserList.getCurrentUser().userID

        if let parent = parent as? PubTabViewController {
            pub = parent.pub
            noteList = NoteList.getWithUserID(
                userID,
                withPubID: Int(pub?.getNumber() ?? "0") ?? 0
            )
            noteList.sort()
            myViewheader.isHidden = true
            tableTopConstraint.constant = 0
            appDelegate.setValue(self, forKey: "pubTrail")
        } else {
            noteList = NoteList.getWithUserID(
                userID,
                withTrailCode: PHAleTrailFactory.getCurrentPHAleTrail().code
            )
            noteList.sort()
            appDelegate.setValue(self, forKey: "myTrail")
        }

        startTrailView.isHidden = TrailList.onTrail() || NoteList.thereAreNotes()
        mainTable.reloadData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWasShown(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillBeHidden(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func notes(at indexPath: IndexPath) -> Note? {
        guard let sections = noteList.getSections() as? [NSArray],
              indexPath.section < sections.count,
              let notes = sections[indexPath.section].object(at: 1) as? [Any],
              indexPath.row < notes.count else {
            return nil
        }
        return notes[indexPath.row] as? Note
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return noteList.getSections().count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = noteList.getSections() as? [NSArray],
              section < sections.count,
              let notes = sections[section].object(at: 1) as? [Any] else {
            return 0
        }
        return notes.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = noteList.getSections() as? [NSArray],
              section < sections.count,
              let pub = sections[section].object(at: 0) as? Pub else {
            return nil
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
        guard let note = notes(at: indexPath) else {
            return UITableViewCell()
        }

        var identifier = "NoteListCellLeft"
        if note.isCurrentUser(withDatabase: nil) {
            identifier = "NoteListCellRight"
        }

        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? NotesListCellTableViewCell
        if cell == nil {
            cell = NotesListCellTableViewCell(style: .default, reuseIdentifier: identifier)
        }

        cell?.note = note
        if let parent = parent as? PubTabViewController {
            cell?.parent = parent
        } else {
            cell?.parent = self
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let note = notes(at: indexPath) else {
            return 0
        }
        return note.getSize().height + 10
    }

    @IBAction func save() {
        guard !text.text.isEmpty else { return }

        if !TrailList.onTrail() {
            PHLogger.showMessage(
                "You must be on the Trail to add a note, please select Start Trail from 'More' menu",
                withViewContoller: self
            )
            return
        }

        guard let note = Note() else { return }
        note.note = text.text

        let gpsLocation = GPSLocation.getInstance() as! GPSLocation
        if pub == nil {
            note.pubID = Int(gpsLocation.currentPub.getNumber()) ?? 0
        } else {
            note.pubID = Int(pub!.getNumber()) ?? 0
        }

        let currentPubID = Int(gpsLocation.currentPub.getNumber()) ?? 0
        if note.pubID != 0 && currentPubID != note.pubID {
            let alert = UIAlertController(
                title: "Info",
                message: "You are not currently in this pub, do you still want to add this note to this pubs story?\n\nYou can add notes between pubs or to the current pub by adding them on the 'Trails' screen",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                self.saveNote(note)
            })
            alert.addAction(UIAlertAction(title: "No", style: .default))
            present(alert, animated: true)
        } else {
            saveNote(note)
        }
    }

    private func saveNote(_ note: Note) {
        guard let config = AppConfiguration() else { return }

        note.appID = Int(config.getAppID())
        note.userID = UserList.getCurrentUser().userID
        note.teamID = TeamList.getCurrentTeam().teamID
        note.trailID = TrailList.getCurrentTrail().trailID
        note.noteType = Note.note_TYPE_NOTE()

        note.insert()

        noteList.add(with: note)
        noteList.sort()
        noteList.resetSections()
        mainTable.reloadData()

        text.text = ""
        view.endEditing(true)
        SendServerThread.start()
        scrollToEnd()
    }

    @IBAction func takePhoto() {
        if !TrailList.onTrail() {
            PHLogger.showMessage(
                "You must be on the Trail to take a photo, please select Start Trail from 'More' menu",
                withViewContoller: self
            )
            return
        }

        let gpsLocation = GPSLocation.getInstance() as! GPSLocation
        if pub != nil && Int(gpsLocation.currentPub.getNumber()) != Int(pub!.getNumber()) {
            let alert = UIAlertController(
                title: "Info",
                message: "You are not currently in this pub, do you still want to add a photo to this pubs story?\n\n You can add photos between pubs or to the current pub by taking a photo on the 'Trails' screen",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
                self.actuallyTakePhoto()
            })
            alert.addAction(UIAlertAction(title: "No", style: .default))
            present(alert, animated: true)
        } else {
            actuallyTakePhoto()
        }
    }

    private func actuallyTakePhoto() {
        let cameraUI = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraUI.sourceType = .camera
        } else {
            cameraUI.sourceType = .photoLibrary
        }
        cameraUI.allowsEditing = false
        cameraUI.delegate = self
        present(cameraUI, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let config = AppConfiguration(), let note = Note() else {
            picker.dismiss(animated: true)
            return
        }

        if pub == nil {
            let gpsLocation = GPSLocation.getInstance() as! GPSLocation
            note.pubID = Int(gpsLocation.currentPub.getNumber()) ?? 0
        } else {
            note.pubID = Int(pub!.getNumber()) ?? 0
        }

        note.appID = Int(config.getAppID())
        note.userID = UserList.getCurrentUser().userID
        note.teamID = TeamList.getCurrentTeam().teamID
        note.trailID = TrailList.getCurrentTrail().trailID
        note.noteType = Note.note_TYPE_PICTURE()

        note.insert()

        let editedImage = info[.editedImage] as? UIImage
        let originalImage = info[.originalImage] as? UIImage
        var imageToSave = editedImage ?? originalImage

        let imageSize = CGSize(width: CGFloat(config.getPhotoWidth()), height: CGFloat(config.getPhotoHeight()))
        imageToSave = MyTrailViewController.scaleImage(imageToSave, toSize: imageSize)

        guard let imageToSave else {
            picker.dismiss(animated: true)
            return
        }

        let imageData = imageToSave.jpegData(compressionQuality: 1.0)

        note.update()

        guard let actualFileName = note.getActualFilename(withDatabase: nil) else {
            picker.dismiss(animated: true)
            return
        }
        try? imageData?.write(to: URL(fileURLWithPath: actualFileName), options: .atomic)

        picker.dismiss(animated: true)

        noteList.add(with: note)
        noteList.sort()
        noteList.resetSections()
        mainTable.reloadData()
        view.endEditing(true)
        scrollToEnd()
        SendServerThread.start()
    }

    @objc static func scaleImage(_ image: UIImage?, toSize newSize: CGSize) -> UIImage? {
        guard let image else { return nil }

        var scaledSize = newSize
        if image.size.width > image.size.height {
            let scaleFactor = image.size.width / image.size.height
            scaledSize.width = newSize.width
            scaledSize.height = newSize.height / scaleFactor
        } else {
            let scaleFactor = image.size.height / image.size.width
            scaledSize.height = newSize.height
            scaledSize.width = newSize.width / scaleFactor
        }

        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

    @objc func keyboardWasShown(_ notification: Notification) {
        guard let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        let movement = kbSize.height
        if movement > 0 && bottomTextEntry.constant == defaultBottomTextEntry {
            bottomTextEntry.constant = movement
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        view.layoutIfNeeded()
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        bottomTextEntry.constant = defaultBottomTextEntry
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
        let loc = sender.location(in: view)
        if let subview = view.hitTest(loc, with: nil), !(subview is UIButton) {
            view.endEditing(true)
        }
    }

    @IBAction func reload() {
        var shouldScroll = false
        if mainTable != nil,
           appeared,
           mainTable.contentOffset.y + 1 >= mainTable.contentSize.height - mainTable.frame.size.height {
            shouldScroll = true
        }

        let userID = UserList.getCurrentUser().userID
        if pub != nil {
            noteList = NoteList.getWithUserID(
                userID,
                withPubID: Int(pub!.getNumber()) ?? 0
            )
        } else {
            noteList = NoteList.getWithUserID(
                userID,
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
        guard noteList.size() > 1,
              let sections = noteList.getSections() as? [NSArray],
              !sections.isEmpty else {
            return
        }

        let lastSection = sections.count - 1
        guard let notes = sections[lastSection].object(at: 1) as? [Any], !notes.isEmpty else {
            return
        }

        let indexPath = IndexPath(row: notes.count - 1, section: lastSection)
        do {
            mainTable.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }

    @IBAction func start() {
        tabBarController?.selectedIndex = 4
        if let nav = tabBarController?.viewControllers?[4] as? UINavigationController,
           let cont = nav.viewControllers.first as? MoreViewController {
            cont.start()
        }
    }
}
