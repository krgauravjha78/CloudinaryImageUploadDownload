//
//  ViewController.swift
//  GetMyParkingAssignment
//
//  Created by iWizards XI on 09/07/19.
//  Copyright © 2019 iWizards XI. All rights reserved.
//

import UIKit
import Cloudinary

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate ,UINavigationControllerDelegate {

    @IBOutlet var collectionViewImage: UICollectionView!
    @IBOutlet var btnSelectMedia: UIButton!
    @IBOutlet var txtFieldResolution: UITextField!
    var resolutionPicker: UIPickerView!
    
    let reuseIdentifier = "collectionCell"
    let picker = UIImagePickerController()
    var selectedImages: [UIImage] = []
    let resolutionPickerValue = ["Select Media Resolution", "50 * 50", "100 * 100", "150 * 150"]
    var cld = CLDCloudinary(configuration: CLDConfiguration(cloudName: AppDelegate.cloudName, secure: true))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resolutionPicker = UIPickerView()
        resolutionPicker.dataSource = self
        resolutionPicker.delegate = self
        txtFieldResolution.inputView = resolutionPicker
        txtFieldResolution.text = resolutionPickerValue[0]
        selectedImages.append(#imageLiteral(resourceName: "carImage"))
    }
    

     // MARK: - Picker View Delegates Method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return resolutionPickerValue.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return resolutionPickerValue[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        txtFieldResolution.text = resolutionPickerValue[row]
        self.selectedImages.removeAll()
        if row == 1 {
            self.getImage(height: 50, width: 50) { (response) in
                DispatchQueue.main.async{
                    self.collectionViewImage.reloadData()
                }
            }
        }else if row == 2{
            self.getImage(height: 100, width: 100) { (response) in
                DispatchQueue.main.async{
                    self.collectionViewImage.reloadData()
                }
            }
        }else if row == 3{
            self.getImage(height: 150, width: 150) { (response) in
                DispatchQueue.main.async{
                    self.collectionViewImage.reloadData()
                }
            }
        }
        self.view.endEditing(true)
    }
    
    
    public func getImage(height: Int, width : Int , completion: @escaping(String) -> ()) {
        
        let transform = CLDTransformation().setWidth(height).setHeight(width).chain().setCrop(.fit)
        let url = cld.createUrl().setTransformation(transform).generate("sample.JPG")
        let request = cld.createDownloader().fetchImage(url!).responseImage { (image, error) in
            if let image1 = image {
                self.selectedImages.append(image1)
                completion("complete")
            }
        }
        request.resume()
       }
    
    
     // MARK: - Collection View Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)
        let img = cell.contentView.viewWithTag(1) as! UIImageView
        img.frame(forAlignmentRect: CGRect(x: 5, y:5, width: 170 , height: 174))
        img.image = selectedImages[indexPath.row]
        cell.backgroundColor = UIColor.cyan
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    
     // MARK: - Button Action
    @IBAction func btnSelectMediaClicked(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallery()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Open the camera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.allowsEditing = true
            picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.present(picker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Open the gallery
    func openGallery(){
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.allowsEditing = true
        picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.present(picker, animated: true, completion: nil)
    }
    
    func dismissVC() {
        dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImages.append(editedImage)
            let imageData: NSData = editedImage.pngData()! as NSData
            cld.createUploader().upload(data: imageData as Data, uploadPreset: AppDelegate.uploadPreset)
        }
        self.collectionViewImage.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

