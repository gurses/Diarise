 //
//  detailedVC.swift
//  Art Book
//
//  Created by Ahmet Malal on 16.01.2018.
//  Copyright © 2018 Ahmet Malal. All rights reserved.
//

import UIKit
import CoreData

class detailedVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var textField: UITextView!
    
    
    var chosenPainting = ""
    let picker = UIDatePicker()
    
    func createDatePicker(){
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        //done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem:.done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: true)
        dateField.inputAccessoryView = toolbar
        dateField.inputView = picker
    }
    @objc func donePressed(){
        //format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let dateString = formatter.string(from: picker.date)
       
        dateField.text = "\(dateString)"
        self.view.endEditing(false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        yearText.delegate = self
        nameText.delegate = self
        artistText.delegate = self
        dateField.delegate = self
        textField.delegate = self as? UITextViewDelegate
        
        
        
        
        
        createDatePicker()
        self.view.backgroundColor = UIColor.orange
        if chosenPainting != ""{ // yeni bir painting oluşturmak istemiyorsa veriyi aktar
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.predicate = NSPredicate(format: "date = %@", self.chosenPainting) // name=%@ eğer chosenPainting name e eşitse onu bul demek ( sadece syntax )
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do{
            let results =  try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let text = result.value(forKey: "text") as? String{
                            textField.text = text
                        }
                        if let date = result.value(forKey: "date") as? String{
                            dateField.text = date
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            self.imageView.image = image
                        }
                    }
                }
            
            }catch{
                print("Error")
            }
            
        }
        
        imageView.isUserInteractionEnabled = true
        let recog = UITapGestureRecognizer(target: self, action: #selector(detailedVC.selectImage ))
        imageView.addGestureRecognizer(recog)
 
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ text: UITextField) -> Bool {
        if text == artistText {
             nameText.becomeFirstResponder()
        }else if text == nameText{
            yearText.becomeFirstResponder()
        }else if text == yearText{
            dateField.becomeFirstResponder()
        }else if text == dateField{
            textField.becomeFirstResponder()
        }else if text == textField{
            text.resignFirstResponder()
        }
        return true
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
 
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //eklemeler
        newArt.setValue(nameText.text, forKey: "name")
        newArt.setValue(textField.text, forKey: "text")
        newArt.setValue(artistText.text, forKey: "artist")
        newArt.setValue(dateField.text, forKey: "date")
        if let year =  Int(yearText.text!){
            newArt.setValue(year, forKey: "year")
        }
        
        let data = UIImageJPEGRepresentation(imageView.image!, 0.5) // 0.5 sıkıştırma oranı kaliteyi yarıya düşürüyor
        newArt.setValue(data, forKey: "image")
        
      // DO-TRY-CATCH hata potansiyeli olan kodları için kullan
        do{
            try context.save()  //  hata olabilir, eğer hata varsa print error
            print("Successful...")
            
        }catch{
            print("Error...")
        }
  
        //yeni bir şey ekledikten sonra onu kaydedip önceki ekrana gitmesi lazım aynı zamanda listeyide refresh etmesi lazım
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPainting"), object: nil) // newPainting sadece bir mesaj, tabi ViewControllerda tekrar çağırmak için kullandığın rawValue ile aynı olması lazım
        self.navigationController?.popViewController(animated: true) // Bulunduğundan bir öncekine git demek (pop)
        
        
    }
    
 
}
