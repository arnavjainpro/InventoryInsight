import SwiftUI

struct ContentView: View {
    @State private var isBusinessViewActive = false
    @State private var isConsumerViewActive = false
    @State private var itemName = ""
    @State private var quantity = ""
    @State private var price = ""
    @State private var receiptItems = ""
    @State private var inventory: [String: (quantity: Int, price: Double)] = [:]
    @State private var salesHistory: [(item: String, price: Double)] = []
    @State private var totalSales: Double = 0.0
    
    func addItem()
    {
        guard let price = Double(price), let quantity = Int(quantity) else { return }
        
        if inventory[itemName] == nil
        {
            inventory[itemName] = (quantity, price)
            itemName = ""
            self.quantity = ""
            self.price = ""
        }
    }
    
    func scanReceipt()
    {
        let receiptItemsArray = receiptItems.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        var total: Double = 0.0
        for item in receiptItemsArray
        {
            if let (quantity, price) = inventory[item], quantity > 0
            {
                inventory[item] = (quantity - 1, price)
                total += price
                salesHistory.append((item: item, price: price))
            }
        }
        totalSales = total
        receiptItems = ""
    }
    
    var body: some View
    {
        NavigationView
        {
            ZStack
            {
                Color(.white)
                    .ignoresSafeArea()
                
                VStack
                {
                    Image("logo")
                        .padding(.top, 90.0)
                    Text("Inventory Insight")
                        .font(.system(size: 40, weight: .light, design: .serif))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(1)
    
                    Button(action:
                            {
                        isBusinessViewActive.toggle()
                    })
                    {
                        VStack
                        {
                            Image("nyc")
                                .cornerRadius(15)
                                .overlay(Text("Business")
                                    .font(.system(size: 40, design: .monospaced))
                                    .foregroundColor(.white)
                                    .background(Color.gray.opacity(0)))
                                .shadow(color:.gray, radius: 5, x:10, y:10)
                            
                        }
                    }
                    .sheet(isPresented: $isBusinessViewActive)
                    {
                        Text("Inventory Management")
                            .font(.title)
                            .padding()
                        
                        HStack
                        {
                            VStack(alignment: .leading)
                            {
                                Text("Item Name:")
                                TextField("Enter item name", text: $itemName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Text("Quantity:")
                                TextField("Enter quantity", text: $quantity)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                
                                Text("Price per Unit ($):")
                                TextField("Enter price", text: $price)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                
                                Button(action: addItem)
                                {
                                    Text("Add Item")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            
                            List(inventory.sorted(by: { $0.key < $1.key }), id: \.key) { item, details in
                                Text("\(item) - \(details.quantity) units - $\(details.price, specifier: "%.2f") per unit")
                            }
                            .frame(width: 200, height: 200)
                        }
                        
                        HStack
                        {
                            VStack(alignment: .leading)
                            {
                                Text("Scan Receipt")
                                Text("(comma-separated):")
                                TextField("Enter receipt items", text: $receiptItems)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: scanReceipt)
                                {
                                    Text("Scan Receipt")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            VStack(alignment: .leading)
                            {
                                Text("Total Sales:")
                                Text("$\(totalSales, specifier: "%.2f")")
                                    .font(.headline)
                                    .padding()
                            }
                            .frame(width: 180)
                        }
                    }
                    .padding()
                    Button(action:
                            {
                        isConsumerViewActive.toggle()
                    })
                    {
                        VStack
                        {
                            Image("people")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 330, height: 180)
                                .cornerRadius(20)
                                .overlay(Text("Consumer")
                                    .font(.system(size: 40, design: .monospaced))
                                    .foregroundColor(.black)
                                    .background(Color.gray.opacity(0)))
                                .shadow(color:.gray, radius: 5, x:10, y:10)
                                .padding(.bottom, 200.0)
                        }
                    }
                    .sheet(isPresented: $isConsumerViewActive)
                    {
                        ConsumerView()
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
    }
    
    struct ContentView_Previews: PreviewProvider
    {
        static var previews: some View
        {
            ContentView()
        }
    }
    
    

    struct ScannedReceipt: Identifiable {
        let id = UUID()
        var items: [String: Double] = [:]
        var totalAmount: Double {
            return items.values.reduce(0, +)
        }

    }
    
    struct ImagePickerView: UIViewControllerRepresentable {
        @Binding var scannedItems: [String: Double]
        var onImageProcessed: ([String: Double]) -> Void

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = context.coordinator
            return imagePicker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            var parent: ImagePickerView

            init(parent: ImagePickerView) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let pickedImage = info[.originalImage] as? UIImage {
                    parent.processImage(pickedImage)
                }
                picker.dismiss(animated: true, completion: nil)
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true, completion: nil)
            }
        }

        func processImage(_ image: UIImage) {
            // Implement image processing here
            // You can extract text and data from the image and update scannedItems
            // Example: scannedItems = processImageAndGetItems(image)
            
            // Once you have processed the image, call the callback
            onImageProcessed(scannedItems)
        }
    }

    
    struct ScannerView: View {
        @Binding var scannedReceipts: [ScannedReceipt]
        @Environment(\.presentationMode) var presentationMode
        @State private var isImagePickerPresented = false
        @State private var scannedItems: [String: Double] = [:]

        var body: some View {
            VStack {
                Text("Camera Scanner")
                    .font(.largeTitle)
                    .padding()

                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("Capture Photo")
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePickerView(scannedItems: $scannedItems) { processedItems in
                        if !processedItems.isEmpty {
                            let newReceipt = ScannedReceipt(items: processedItems)
                            scannedReceipts.append(newReceipt)
                        }
                    }
                }
            }
            .padding()
        }
    }

    struct ConsumerView: View
    {
        
        @State private var isShowingScanner = false
        @State private var scannedReceipts: [ScannedReceipt] = []
        
        func scanReceipt1() {
              // Simulate scanning and adding a receipt to the list
              let newReceipt = ScannedReceipt(items: ["Item 1": 10.99, "Item 2": 5.99, "Item 3": 8.49])
              scannedReceipts.append(newReceipt)
          }

          func addNewReceipt() {
              let newReceipt = ScannedReceipt(items: ["Item 4": 7.99, "Item 5": 12.99, "Item 6": 15.49])
              scannedReceipts.append(newReceipt)
          }

        var body: some View
        {
            NavigationView {
                        VStack {
                            Button(action: {
                                self.isShowingScanner.toggle()
                            }) {
                                Text("Scan Receipt")
                                    .font(.title)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }

                            List {
                                ForEach(scannedReceipts) { receipt in
                                    Section(header: Text("Receipt \(String(receipt.id.uuidString.prefix(6)))")) {
                                        ForEach(receipt.items.sorted(by: { $0.key < $1.key }), id: \.key) { item, price in
                                            Text("\(item): $\(price, specifier: "%.2f")")
                                        }
                                        Text("Total Amount: $\(receipt.totalAmount, specifier: "%.2f")")
                                    }
                                }
                            }
                            .listStyle(InsetGroupedListStyle())
                            .padding(.top)

                            if !scannedReceipts.isEmpty {
                                Button(action: addNewReceipt) {
                                    Text("Add New Receipt")
                                        .font(.title)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }

                        }
                        .navigationBarTitle("Receipt Scanner")
                    }
                    .sheet(isPresented: $isShowingScanner, onDismiss: scanReceipt1) {
                        ScannerView(scannedReceipts: $scannedReceipts)
                    }
        }
    }
}
