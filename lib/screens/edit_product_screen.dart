import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product-screen';
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imargeUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');

  bool _isInit = true;
  var _initValue = {
    'id': '',
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  @override
  void initState() {
    _imargeUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        var productID = ModalRoute.of(context)?.settings.arguments as String;
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productID);

        _initValue = {
          'id': _editedProduct.id,
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '', //down there control doesnot work with initial values
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imargeUrlFocusNode.removeListener(_updateImageUrl);
    _imargeUrlFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imargeUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg') &&
              !_imageUrlController.text.endsWith('.png'))) {
        return;
      }

      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState?.save();
    if (_editedProduct.id != '') {
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      Provider.of<ProductsProvider>(context, listen: false)
          .addProduct(_editedProduct);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
              onPressed: () {
                _saveForm();
              },
              icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValue['title'],
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_priceFocusNode),
                validator: (value) {
                  //return null means no error, return any string mean 'string' is error
                  if (value!.isEmpty) return 'Please enter title';
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: value!,
                    description: _editedProduct.description,
                    price: _editedProduct.price,
                    imageUrl: _editedProduct.imageUrl,
                    isFavourite: _editedProduct.isFavourite,
                  );
                },
              ),
              TextFormField(
                initialValue: _initValue['price'],
                decoration: const InputDecoration(labelText: 'price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_descriptionFocusNode),
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    description: _editedProduct.description,
                    price: double.parse(value!),
                    imageUrl: _editedProduct.imageUrl,
                    isFavourite: _editedProduct.isFavourite,
                  );
                },
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter price';
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Price should be greater than 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValue['description'],
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please Enter a description';
                  }
                  if (value.length < 10) {
                    return 'too short - should be at least 10 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: _editedProduct.title,
                    description: value!,
                    price: _editedProduct.price,
                    imageUrl: _editedProduct.imageUrl,
                    isFavourite: _editedProduct.isFavourite,
                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, right: 10),
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: _imageUrlController.text.isEmpty
                        ? const Text(
                            'Enter a Url',
                            textAlign: TextAlign.center,
                          )
                        : FittedBox(
                            fit: BoxFit.cover,
                            child: Image.network(_imageUrlController.text),
                          ),
                  ),
                  Expanded(
                      child: TextFormField(
                    // initialValue: _initValue['imageUrl'],
                    decoration: const InputDecoration(labelText: 'Image Url'),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    controller: _imageUrlController,
                    focusNode: _imargeUrlFocusNode,
                    onFieldSubmitted: (_) => _saveForm(),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter image url';
                      if (!value.startsWith('http') &&
                          !value.startsWith('https')) {
                        return 'Please enter valid url';
                      }
                      if (!value.endsWith('.jpg') &&
                          !value.endsWith('.jpeg') &&
                          !value.endsWith('.png')) {
                        return 'Please enter image url';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                        id: _editedProduct.id,
                        title: _editedProduct.title,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                        imageUrl: value!,
                        isFavourite: _editedProduct.isFavourite,
                      );
                    },
                  ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
***SOME TIPS USING LISTVIEW OR COLUMN AS INPUT FORM 
ListView or Column
When working with Forms, you typically have multiple input fields above each other - that's why you might want to ensure that the list of inputs is scrollable. Especially, since the soft keyboard will also take up some space on the screen.
For very long forms (i.e. many input fields) OR in landscape mode (i.e. less vertical space on the screen), you might encounter a strange behavior: User input might get lost if an input fields scrolls out of view.
That happens because the ListView widget dynamically removes and re-adds widgets as they scroll out of and back into view.

For short lists/ portrait-only apps, where only minimal scrolling might be needed, a ListView should be fine, since items won't scroll that far out of view (ListView has a certain threshold until which it will keep items in memory).
But for longer lists or apps that should work in landscape mode as well - or maybe just to be safe - you might want to use a Column (combined with SingleChildScrollView) instead. Since SingleChildScrollView doesn't clear widgets that scroll out of view, you are not in danger of losing user input in that case.

For example:
Form(
    child: ListView(
        children: [ ... ],
    ),
),

simply becomes

Form(
    child: SingleChildScrollView(
        child: Column(
            children: [ ... ],
        ),
    ),
),
*/
