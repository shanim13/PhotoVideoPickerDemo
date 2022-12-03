//
//  ViewController.swift
//  Gallery
//
//  Created by IE06 on 13/09/22.
//

import UIKit
import PhotosUI
import AVKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIVideoEditorControllerDelegate, AVPlayerViewControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var chooseButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var rotationGesture: UIRotationGestureRecognizer!
    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    var player = AVPlayer()
    var videoURL: URL?
    var playerController = AVPlayerViewController()
    var value = 0
    @IBOutlet var segmentCamera: UISegmentedControl!
    
    @IBOutlet var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.isHidden = true
        actionSheet()
        
        rotationGesture.delegate = self
        pinchGesture.delegate = self
        pinchGesture.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func longPressGesture(_ sender: Any) {
        showTrim()
    }
    @IBAction func rotationGesture(_ sender: Any) {
        guard let rotationview = rotationGesture.view else{return}
        rotationview.transform = rotationview.transform.rotated(by: rotationGesture.rotation)
        rotationGesture.rotation = 0
    }
    
    @IBAction func pinchGesture(_ sender: Any) {
        guard let pinchview = pinchGesture.view else{return}
        pinchview.transform = pinchview.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
        pinchGesture.scale = 1
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began || sender.state == .changed{
            let translation = sender.translation(in: sender.view)
            let changeX = (sender.view?.center.x)! + translation.x
            let changeY = (sender.view?.center.y)! + translation.y
            sender.view?.center = CGPoint(x: changeX, y: changeY)
            sender.setTranslation(CGPoint.zero, in: sender.view)
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UIRotationGestureRecognizer || gestureRecognizer is UIPinchGestureRecognizer ) {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func chooseButton(_ sender: UIButton) {
        actionSheet()
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
//        trimVideo()
        if(imageView.image != nil){
            showAlert()
        }
    }
    
    @IBAction func segmentCamera(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            actionSheetCamera()
        }
        else if sender.selectedSegmentIndex == 1{
            actionSheet()
        }
    }
    
    
    func showTrim(){
        let trimalert = UIAlertController(title: "Video Edit", message: "", preferredStyle: .alert)
        trimalert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler:nil))
        trimalert.addAction(UIAlertAction(title:"Trim", style: .default,  handler: {action in
            
            let video = self.videoURL!// videosArray is a list of URL instances
                if UIVideoEditorController.canEditVideo(atPath: video.path){
                  let editController = UIVideoEditorController()
                    editController.delegate = self
                  editController.videoPath = video.path
                  editController.delegate = self
                  self.present(editController, animated:true)
                }
                else{
                  let alert = UIAlertController(title: "Can’t edit ", message: "This video was not supported", preferredStyle: .alert)
                  let gotIt = UIAlertAction(title: "Got it", style: .cancel) { (action) in
                  }
                  alert.addAction(gotIt)
                  self.present(alert, animated: true, completion: nil)
                }
        }))
        present(trimalert,animated: true, completion: nil)
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "DELETE", message: "Are you sure you want to delete?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.imageView.image = nil
            self.dismiss( animated: true, completion: nil)
            self.playButton.isHidden = true
        }))
        present(alert,animated: true, completion: nil)
    }
    
    func actionSheetCamera(){
        let actionSheet = UIAlertController(title: "OPEN CAMERA!!", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "CAMERA", style: .default, handler: { action in
            self.value = 3
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.allowsEditing = true
            
            self.present(picker, animated: true, completion: nil)
    }))
        actionSheet.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler:nil))
        present(actionSheet, animated: true)
        }
    
    func actionSheet(){
        let actionSheet = UIAlertController(title: "UPLOAD!!", message: "What do you want to upload?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "PHOTOS", style: .default, handler: { action in
            self.value = 1
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.allowsEditing = true
            self.imageView.transform = .identity
            self.present(picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "VIDEOS", style: .default, handler: { action in
            self.value = 2
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.sourceType = .photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
            picker.mediaTypes = ["public.movie"]
            
            //            picker.videoQuality = .typeHigh
            //            picker.videoExportPreset = AVAssetExportPresetHEVC1920x1080
            picker.allowsEditing = true
            
            self.imageView.transform = .identity
            self.present(picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler:nil))
        
        present(actionSheet, animated: true)
    }
    
    func playVideo() {
        player = AVPlayer(url: videoURL!)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true){
            playerController.player!.play()
        }
        player.play()
    }
    
//    func trimVideo(){
//        let sheet = UIAlertController(title: "Select option", message: "Do you want to edit video", preferredStyle:.actionSheet)
//        let trim = UIAlertAction(title: "Trim video", style: .default) { [self] (action) in
//    //      print(“UIVideoEditor”)
//          let video = self.videoURL!// videosArray is a list of URL instances
//            if UIVideoEditorController.canEditVideo(atPath: videoURL!.path) {
//            let editController = UIVideoEditorController()
//            editController.videoPath = videoURL!.path
//            editController.delegate = self
//            self.present(editController, animated:true)
//          }
//    //      else{
//    //        let alert = UIAlertController(title: “Can’t play “, message: “This video was not supported”, preferredStyle: .alert)
//    //        let gotIt = UIAlertAction(title: “Got it”, style: .cancel) { (action) in
//    //        }
//    //        alert.addAction(gotIt)
//    //        self.present(alert, animated: true, completion: nil)
//    //      }
//        }
//        sheet.addAction(trim)
//        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//        }
//    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if value == 1{
            imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.dismiss(animated: true,completion: nil)
            imageView.transform = .identity
        }
        
        if value == 2{
            videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            
            func generateThumbnail(path: URL) -> UIImage? {
                do {
                    let asset = AVURLAsset(url: videoURL! as URL, options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    return thumbnail
                }
                catch let error {
                    print("Error Building thumbnail: \(error.localizedDescription)")
                    return nil
                }
            }
            imageView.image = generateThumbnail(path: videoURL! as URL)
            playButton.isHidden = false
            self.dismiss(animated: true,completion: nil)
            imageView.transform = .identity
        }
                imageView.transform = .identity
        if value == 3 {
            imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.dismiss(animated: true,completion: nil)
            imageView.transform = .identity
        }
    }
    @IBAction func playButton(_ sender: UIButton) {
        playVideo()
    }
}
