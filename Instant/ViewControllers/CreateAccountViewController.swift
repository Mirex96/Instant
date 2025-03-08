import UIKit
import FirebaseAuth
import FirebaseDatabase


class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinAccountTextView: UITextView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.clipsToBounds = true
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let atributedString = NSMutableAttributedString(string: "Already have an account? Sign in here.", attributes: [.font: Font.caption])
        atributedString.addAttribute(.link, value: "instantcreate://createAccount", range: (atributedString.string as NSString).range(of: "Sign in here."))
        signinAccountTextView.attributedText = atributedString
        signinAccountTextView.linkTextAttributes = [.foregroundColor: UIColor.secondaryColor, .font: Font.linkLabel]
        signinAccountTextView.delegate = self
        signinAccountTextView.isScrollEnabled = false
        signinAccountTextView.textAlignment = .center
        signinAccountTextView.isEditable = false
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)) // убираем клавиатуру по тапу на экран
        view.addGestureRecognizer(backgroundTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboarNotifications()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardOffset = view.convert(keyboardFrame.cgRectValue, from: nil).size.height  // высота клавиатуры
        let totalOffset = activeTextField == nil ? keyboardOffset : keyboardOffset + activeTextField!.frame.height // общее смещение
        scrollView.contentInset.bottom = totalOffset
    }
    
    // Когда клавиатура скрыта мы возвращаем все занчения в исходное положение
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    // Метод сктытия клавиатуры
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text else {
            presentErrorAlert(title: "Username Required", message: "Please inter a username to continue.")
            return
        }
        guard username.count >= 3 && username.count <= 15 else {  // проверка на правильность введонного имени
            presentErrorAlert(title: "Username Invalid", message: "Please inter a username between 3 and 15 characters long.")
            return
        }
        guard let password = passwordTextField.text else {
            presentErrorAlert(title: "Password Required", message: "Please inter a password to continue.")
            return
        }
        guard let email = emailTextField.text else {
            presentErrorAlert(title: "Email Required", message: "Please inter an email to continue.")
            return
        }
        
       
        showLoadingView()
        Database.database().reference().child("username").child(username).observeSingleEvent(of: .value) { snapshot in
            guard  !snapshot.exists() else {
                self.presentErrorAlert(title: "Username In Use", message: "Please try a different username")
                self.removeLoadingView()
                return
            }
            
            // учетная запись пользователя с помощью Firebase:
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                self.removeLoadingView()
                if let error = error {
                    print(error.localizedDescription) // оператор выведет ошибку если она есть, если реультат нулевой
                    var errorMesage = "Something went wrong. Please try again later"
                    if let nsError = error as NSError? {
                        let authError = AuthErrorCode(rawValue: nsError.code)
                        switch authError {
                        case .emailAlreadyInUse:
                            errorMesage = "Email already in use"
                        case .invalidEmail:
                            errorMesage = "Invalid Email"
                        case .weakPassword:
                            errorMesage = "Weak password"
                        default:
                            break
                        }
                    }
                    self.presentErrorAlert(title: "Create Account Failed", message: errorMesage)
                    return
                }
                guard let result = result else {
                    self.presentErrorAlert(title: "Create Account Failed", message: "Something went wrong. Please try again later")
                    return
                }
                let userId = result.user.uid
                let userData: [String: Any] = [
                    "id": userId,
                    "username": username
                ]
                Database.database().reference().child("users").child(userId).setValue(userData) // аккаунт создан и имя успешно сохранено в Database
                Database.database().reference().child("username").child(username).setValue(userData)
                
                // константа для хранения экземпляра страницы пользователя после успешной регистрации или входа
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeVC = mainStoryboard.instantiateViewController(withIdentifier: "HomeViewController")
                let navVc = UINavigationController(rootViewController: homeVC)
                let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow } // получили доступ к окну
                window?.rootViewController = navVc
            }
        }
        
    }
    

    
}

extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextField = nil
    }
}

extension CreateAccountViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "instantcreate" {
            performSegue(withIdentifier: "SignInSegue", sender: nil)
        }
        return false
    }
}
