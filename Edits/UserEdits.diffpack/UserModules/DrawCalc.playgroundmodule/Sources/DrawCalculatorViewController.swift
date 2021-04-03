import UIKit
import PencilKit
import PlaygroundSupport

public class DrawCalculatorViewController: UIViewController {
    
    // All the class's used UI components
    var canvas: PKCanvasView!
    var navigationBar: UINavigationBar!
    var expressionLabel: ExpressionLabel!
    
    // The handler for OCR operations
    var ocrHandler: OCRHandler!
    
    /// Setup all of the needed items for the canvas (UI and OCR)
    /// Items include a navbar, canvas, and a label for UI along with the OCR and its listener
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // OCR initialization
        initializeOCR()
        setupNavBar()
        initializeCanvas()
        initializeLabel()
        initializeConstraints()
    }
    
    /// Make sure all constraints and subviews are loaded and then set up the label view
    public override func viewDidAppear(_ animated: Bool) {
        resetLabel()
    }
    
    /// A Method to setup the navigation bar and its shown buttons
    /// Currently sets the title and adds the canvas clear and erase buttons
    func setupNavBar() {
        navigationBar = UINavigationBar()
        view.backgroundColor = .systemBackground
        self.view.addSubview(navigationBar)
        // Create the actual item and add both right bar button items
        let navigationItem = UINavigationItem(title: "DrawCalc")
        navigationItem.rightBarButtonItems = [createTrashItem(), createEraseItem()]
        navigationBar.setItems([navigationItem], animated: false)
        view.addSubview(navigationBar)
    }
    
    /// A method to create the item for the canvas clear button
    /// Uses the trash SFSymbol
    func createTrashItem() -> UIBarButtonItem {
        let button = createButtonItem(image: UIImage(systemName: "trash")!)
        button.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    /// A method to create the erase/pen tool toggle
    /// Uses the scribble SFSymbol and erase material icon
    func createEraseItem() -> UIBarButtonItem {
        let highlighted = UIImage(systemName: "scribble")
        let button = createButtonItem(image: UIImage(named: "erase")!.withTintColor(.systemBlue), selected: highlighted)
        button.addTarget(self, action: #selector(toggleEraser(sender:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    /// A method to create a generic button with a given image and potential selected image 
    func createButtonItem(image: UIImage, selected: UIImage? = nil) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        if let selected = selected {
            button.setImage(selected, for: .selected)
        }
        button.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        return button
    }
    
    /// A method to initialize the drawable PKCanvas with the OCRHandler as its delegate
    /// Sets the default tool as well
    func initializeCanvas() {
        canvas = PKCanvasView()
        canvas.backgroundColor = .clear 
        canvas.delegate = ocrHandler
        canvas.becomeFirstResponder()
        canvas.tool = PKInkingTool(.pen, color: .blue, width: 20)
        view.addSubview(canvas)
    }
    
    /// A method to initialize the top expression label
    func initializeLabel() {
        expressionLabel = ExpressionLabel()
        view.addSubview(expressionLabel)
    }
    
    /// A method to initialize the OCR handler for this ViewController
    func initializeOCR() {
        ocrHandler = OCRHandler(onResult: onOCRResult)
    }
    
    /// A method to initialize all of the UI constraints on this ViewController
    func initializeConstraints() {
        // Get the passed TabBar
        let tabBar = tabBarController!.tabBar
        
        // Set up all constraints for the navigation bar
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        // Setup all constraints for the expressionLabel
        expressionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expressionLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            expressionLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            expressionLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            expressionLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Setup all constraints for the canvas
        canvas.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: expressionLabel.bottomAnchor),
            canvas.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    /// A callback method with a given OCR Result
    func onOCRResult(result: String) {
        DispatchQueue.main.sync {
            expressionLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
            expressionLabel.font = .systemFont(ofSize: 50)
            expressionLabel.text = result
        }
    }
    
    func resetLabel() {
        expressionLabel.font = .systemFont(ofSize: 30)
        expressionLabel.textAlignment = .center
        expressionLabel.textColor = .placeholderText
        expressionLabel.text = "Write Problem Below"
    }
    
    @objc func clearCanvas() {
        canvas.drawing = PKDrawing()
        resetLabel()
    }
    
    @objc func toggleEraser(sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            canvas.tool = PKEraserTool(.bitmap)
        } else {
            canvas.tool = PKInkingTool(.pen, color: .blue, width: 20)
        }
    }
}

