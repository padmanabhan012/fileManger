//
//  FolderDetailsViewController.swift
//  FileManager
//
//  Created by Rahul P John on 19/01/25.
//

import UIKit

class FolderDetailsViewController: UIViewController {
    
    @IBOutlet weak var folderDetailCollectionView: UICollectionView!
    
    var fileList = [AddFiles]()
    var parentID = String()
    var parentName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIDecoration()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    private func UIDecoration() {
        configNavBar()
    }
    
    private func configNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        title = parentName
        
        // implementing left nav button for add new folder
        self.navigationItem.setRightBarButton(createAddFileButton(), animated: true)
    }
    
    func createAddFileButton() -> UIBarButtonItem {
        let addNewFolder = UIButton()
        addNewFolder.setImage(UIImage(systemName: "plus"), for: .normal)
        addNewFolder.addTarget(self, action: #selector(didTapAddFolderButton(_:)), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: addNewFolder)
        return leftBarButton
    }
    
    // Button Actions
    
    @objc
    private func didTapAddFolderButton(_ sender: UIButton) {
        // Create an image picker controller
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary  // Use .camera for camera input
        
        // Optionally, configure additional properties (e.g., allowing editing)
        imagePickerController.allowsEditing = true
        
        // Present the image picker
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc
    private func didTapFavouriteButton(_ sender: UIButton) {
        print("Success")
    }
    
    private func addFolderPopup() {
        let alert = UIAlertController(title: "Add Folder", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter folder name"
        }
        let createAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let textField = alert.textFields?.first else { return }
            
            DataManager.sharedData.createFolder(folderName: textField.text ?? "Untitled Folder", isFolder: true, isFavourite: false) { [weak self] isSuccess in
                guard let self = self else { return }
                if isSuccess {
                    fetchData()
                } else {
                    let alert = UIAlertController(title: "File Manager", message: "Error while saving data", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    present(alert, animated: true)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func fetchData() {
        DataManager.sharedData.fetchData1 { [weak self] isValid, fetchedData in
            guard let self = self else { return }
            if isValid {
                guard let fetchedData = fetchedData else {
                    let alert = UIAlertController(title: "File Manager", message: "Something went wrong", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    present(alert, animated: true)
                    return
                }
                fileList = fetchedData.filter({ $0.parentID == self.parentID })
                folderDetailCollectionView.delegate = self
                folderDetailCollectionView.dataSource = self
                folderDetailCollectionView.reloadData()
            } else {
                let alert = UIAlertController(title: "File Manager", message: "Error while fetching data", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                present(alert, animated: true)
            }
        }
    }
}


extension FolderDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let fileListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderDetailsCollectionViewCell", for: indexPath) as? FolderDetailsCollectionViewCell else { return UICollectionViewCell() }
        let data = fileList[indexPath.item]
        fileListCell.lblFileName.text = data.fileName ?? ""
        if let fileData = data.fileData {
            fileListCell.imgFile.image = UIImage(data: fileData)
        }
        return fileListCell
    }
}

extension FolderDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellRect = CGSize(width: collectionView.frame.size.width / 4, height: 105.00)
        return cellRect
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension FolderDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            guard let data = image.pngData() else { return }
            DataManager.sharedData.createFolder(fileData: data, fileName: "img_\(Date.now)", fileType: "image", isFolder: false, parentID: parentID, isFavourite: false) { [weak self] isSuccess in
                guard let self = self else { return }
                if isSuccess {
                    fetchData()
                } else {
                    print("Something went wrong")
                }
            }
        } else if let image = info[.originalImage] as? UIImage {
            guard let data = image.pngData() else { return }
            DataManager.sharedData.createFolder(fileData: data, fileName: "img_\(Date.now)", fileType: "image", isFolder: false, parentID: parentID, isFavourite: false) { [weak self] isSuccess in
                guard let self = self else { return }
                if isSuccess {
                    fetchData()
                } else {
                    print("Something went wrong")
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Image picker was cancelled")
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
}
