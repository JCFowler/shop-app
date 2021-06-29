import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';

class EditProductScreen extends StatefulWidget {
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var _isLoading = false;
  final _imageUrlController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _edittedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
  };

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageUrlController.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm(BuildContext context) {
    setState(() {
      _isLoading = true;
    });
    if (_form.currentState != null) {
      if (_form.currentState!.validate()) {
        _form.currentState!.save();
        if (_edittedProduct.id.isEmpty) {
          Provider.of<Products>(context, listen: false)
              .addProduct(_edittedProduct)
              .catchError((error) {
            return showDialog<Null>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('An Error occurred...'),
                content: Text('Something went wrong...'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('Okay'),
                  ),
                ],
              ),
            );
          }).then((_) {
            setState(() {
              _isLoading = true;
            });
            Navigator.of(context).pop();
          });
        } else {
          setState(() {
            _isLoading = true;
          });
          Provider.of<Products>(context, listen: false)
              .editProduct(_edittedProduct)
              .then(
            (_) {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pop();
            },
          );
        }
      }
    }
  }

  void updateEdittedProduct({
    String id = '',
    String title = '',
    String description = '',
    int price = 0,
    String imageUrl = '',
  }) {
    _edittedProduct = Product(
      id: id.isEmpty ? _edittedProduct.id : id,
      title: title.isEmpty ? _edittedProduct.title : title,
      description:
          description.isEmpty ? _edittedProduct.description : description,
      price: price == 0 ? _edittedProduct.price : price,
      imageUrl: imageUrl.isEmpty ? _edittedProduct.imageUrl : imageUrl,
      isFavorite: _edittedProduct.isFavorite,
    );
  }

  validateInput({
    String? value,
    String errorMessage = 'Needs Input',
    bool isNumber = false,
  }) {
    if (isNumber) {
      if (value != null && value.isEmpty) {
        return errorMessage;
      } else if (int.tryParse(value!) == null) {
        return 'Needs to be a vaild Number.';
      } else if (int.parse(value) <= 0) {
        return 'Number needs to be greater than 0.';
      } else {
        return null;
      }
    } else {
      if (value != null && value.isEmpty) {
        return errorMessage;
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      final oldProduct =
          Provider.of<Products>(context, listen: false).findById(id);
      _edittedProduct = oldProduct;
      _initValues = {
        'title': _edittedProduct.title,
        'description': _edittedProduct.description,
        'price': _edittedProduct.price.toString(),
      };
      _imageUrlController.text = _edittedProduct.imageUrl;
      print(_edittedProduct.imageUrl);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _edittedProduct.id.isNotEmpty ? 'Edit Product' : 'Add New Product'),
        actions: [
          IconButton(
            onPressed: () => _saveForm(context),
            icon: Icon(
              Icons.save,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                  key: _form,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: InputDecoration(labelText: 'Title'),
                          textInputAction: TextInputAction.next,
                          validator: (value) => validateInput(
                              value: value,
                              errorMessage: 'Product needs a title.'),
                          onSaved: (value) =>
                              updateEdittedProduct(title: value!),
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: Platform.isIOS
                              ? TextInputType.numberWithOptions(
                                  signed: true,
                                  decimal: false,
                                )
                              : TextInputType.number,
                          validator: (value) => validateInput(
                              value: value,
                              errorMessage: 'Need to add a price.',
                              isNumber: true),
                          onSaved: (value) =>
                              updateEdittedProduct(price: int.parse(value!)),
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          validator: (value) => validateInput(
                              value: value, errorMessage: 'Needs Description'),
                          onSaved: (value) =>
                              updateEdittedProduct(description: value!),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ),
                              child: Container(
                                child: _imageUrlController.text.isEmpty
                                    ? Container(
                                        alignment: Alignment.center,
                                        child: Text('Enter a URL'),
                                      )
                                    : FittedBox(
                                        child: Image.network(
                                          _imageUrlController.text,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                // initialValue: _initValues['imageUrl'],
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageUrlController,
                                focusNode: _imageFocusNode,
                                onEditingComplete: () {
                                  setState(() {});
                                  _saveForm(context);
                                },
                                onFieldSubmitted: (_) => _saveForm,
                                validator: (value) => validateInput(
                                    value: value,
                                    errorMessage: 'Needs Vaild URL'),
                                onSaved: (value) =>
                                    updateEdittedProduct(imageUrl: value!),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
    );
  }
}
