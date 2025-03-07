import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var createAccountTextView: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.clipsToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let atributedString = NSMutableAttributedString(string: "Don't have an account? Create an account here", attributes: [.font: Font.caption])
        atributedString.addAttribute(.link, value: "instantsignin://signinAccount", range: (atributedString.string as NSString).range(of: "Create an account here"))
        createAccountTextView.attributedText = atributedString
        createAccountTextView.linkTextAttributes = [.foregroundColor: UIColor.secondaryColor, .font: Font.linkLabel]
        createAccountTextView.delegate = self
        createAccountTextView.isScrollEnabled = false
        createAccountTextView.textAlignment = .center
        createAccountTextView.isEditable = false
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)) // убираем клавиатуру по тапу на экран
        view.addGestureRecognizer(backgroundTap)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 20
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboarNotifications()  // удаляем уведомление
    }
    
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    // метод для удаления уведомлений когда клавиатура исчезнет
    func removeKeyboarNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardOffset = view.convert(keyboardFrame.cgRectValue, from: nil).size.height  // высота клавиатуры
        let totalOffset = activeTextField == nil ? keyboardOffset : keyboardOffset + activeTextField!.frame.height // общее смещение
        scrollView.contentInset.bottom = totalOffset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
     
    // Метод сктытия клавиатуры
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func signinButtonTapped(_ sender: Any) {
        guard let password = passwordTextField.text else {
            presentErrorAlert(title: "Password Required", message: "Please inter a password to continue.")
            return
        }
        guard let email = emailTextField.text else {
            presentErrorAlert(title: "Email Required", message: "Please inter an email to continue.")
            return
        }
        showLoadingView() // экран загрузки
        signinUser(email: email, password: password) { [weak self] successe, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error)
                strongSelf.presentErrorAlert(title: "Signin Error", message: error)
                return
            }
            // константа для хранения экземпляра страницы пользователя после успешной регистрации или входа
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController")
            let navVc = UINavigationController(rootViewController: homeVC)
            let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow } // получили доступ к окну
            window?.rootViewController = navVc
        }
        
    }
    
    func signinUser(email: String, password: String, completion: @escaping (_ successe: Bool, _ error: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            //self.removeLoadingView() // убираем экран загрузки
            if let error = error {
                print(error.localizedDescription)
                var errorMesage = "Something went wrong. Please try again later"
                if let nsError = error as NSError? {
                    let authError = AuthErrorCode(rawValue: nsError.code)
                    switch authError {
                    case .userNotFound:
                        errorMesage = "Email/Password does not match any records"
                    case .invalidEmail:
                        errorMesage = "Invalid Email"
                    default:
                        break
                    }
                }
                completion(false, errorMesage)
                return
            }
            completion(true, nil)
        }
    }
    
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextField = nil
    }
    
}

extension SignInViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "instantsignin" {
            performSegue(withIdentifier: "CreateAccountSegue", sender: nil)
        }
        return false
    }
}
