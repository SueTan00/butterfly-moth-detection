
import UIKit
import Firebase
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    var storage: Storage!
    var firestore: Firestore!

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var resultText: UITextView!
    @IBOutlet weak var predictedImgView: UIImageView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var noTaylorText: UITextView!
    
    @IBAction func selectImg(_ sender: Any) {
        print("button pressed!")
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo lib")
            return
        }
        self.predictedImgView.image = nil
        self.resultText.text = ""
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        spinner.isHidden = false
        spinner.startAnimating()
        
        let imageURL = info[UIImagePickerControllerImageURL] as? URL
        let imageName = imageURL?.lastPathComponent
        print(imageName!)
        let storageRef = storage.reference().child("images").child(imageName!)

        storageRef.putFile(from: imageURL!, metadata: nil) { metadata, error in
            if let error = error {
                print(error)
            } else {
                self.resultText.text = "upload success!"

                self.firestore.collection("predicted_images").document(imageName!)
                    .addSnapshotListener { documentSnapshot, error in
                        if let error = error {
                            print("error occurred\(error)")
                        } else {
                            print("here")
                            if (documentSnapshot?.exists)! {
//                                print(documentSnapshot?.data())
                                let imageData = (documentSnapshot?.data())
                                self.visualizePrediction(imgData: imageData)
                            } else {
                                self.resultText.text = "waiting for prediction data..."
                            }

                        }
                }

            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func visualizePrediction(imgData: [String: Any]?) {
        var label_name: String = ""
        self.spinner.stopAnimating()
        self.spinner.isHidden = true
        let confidence = imgData!["confidence"] as! Double * 100
        let label_id = imgData!["label_name"] as? NSNumber
        if(label_id == 1){
            label_name = "Cethosia Cydippe"
        }else if(label_id == 2){
            label_name = "Danaid Eggfly"
        }else if(label_id == 3){
            label_name = "Alucitidae"
        }else if(label_id == 4){
            label_name = "Apape Chloropyga"
        }else if(label_id == 5){
            label_name = "Swamp Tiger"
        }else if(label_id == 6){
            label_name = "Argyreus Hyperbius"
        }else if(label_id == 7){
            label_name = "Bird Wing"
        }else if(label_id == 8){
            label_name = "Black-spotted White"
        }else if(label_id == 9){
            label_name = "Bogong"
        }else if(label_id == 10){
            label_name = "Emperor Gum"
        }else if(label_id == 11){
            label_name = "Euploea Alcathoe"
        }else if(label_id == 12){
            label_name = "Euploea Tulliolus"
        }else if(label_id == 13){
            label_name = "Giant Wood"
        }else if(label_id == 14){
            label_name = "Golden Sun"
        }else if(label_id == 15){
            label_name = "Grapevine"
        }else if(label_id == 16){
            label_name = "Graphium Eurypylus"
        }else if(label_id == 17){
            label_name = "Graphium Macfarlanei"
        }else if(label_id == 18){
            label_name = "Graphium Macleayanus"
        }else if(label_id == 19){
            label_name = "Leaf Wing"
        }else if(label_id == 20){
            label_name = "Lichen"
        }else if(label_id == 21){
            label_name = "Monarch"
        }else if(label_id == 22){
            label_name = "Purple Beak"
        }else if(label_id == 23){
            label_name = "Red-banded Jezebel"
        }else if(label_id == 24){
            label_name = "Samia Cynthia"
        }else if(label_id == 25){
            label_name = "Thallarcha Albicollis"
        }else if(label_id == 26){
            label_name = "Uraniidae"
        }else if(label_id == 27){
            label_name = "Vindula Arsinoe"
        }else if(label_id == 28){
            label_name = "Eschemon Rafflesia"
        }else if(label_id == 29){
            label_name = "White-banded Plane"
        }else {
            label_name = "nothing"
        }
        
        if (imgData!["image_path"] as! String).isEmpty {
            self.resultText.text = "No Butterfly/Moth found 😢"
        } else {
            let predictedImgRef = storage.reference(withPath: imgData!["image_path"] as! String)
            predictedImgRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else {
                    let image = UIImage(data: data!)
                    self.resultText.text = "Found \(label_name)! \(String(format: "%.2f", confidence))% confidence"
                    self.predictedImgView.contentMode = .scaleAspectFit
                    self.predictedImgView.image = image
                }
            }
        }


    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        storage = Storage.storage()
        firestore = Firestore.firestore()
        spinner.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

