import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/offer_model.dart';
import '../../providers/offers_provider.dart';
import '../../widgets/projects/image_picker.dart';
import '../../widgets/projects/multi_image_picker.dart';


class AddOfferSheet extends StatefulWidget {
  final OfferModel? offer;

  const AddOfferSheet({Key? key, this.offer}) : super(key: key);

  @override
  _AddOfferSheetState createState() => _AddOfferSheetState();
}

class _AddOfferSheetState extends State<AddOfferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountController = TextEditingController();
  DateTime? _validUntil;
  List<File> _images = [];
  String? _providerLogo;
  File? _providerLogoFile;
  bool _isPercentage = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      _titleController.text = widget.offer!.title;
      _detailsController.text = widget.offer!.details;
      _providerNameController.text = widget.offer!.serviceProviderName;
      _originalPriceController.text = widget.offer!.originalPrice?.toString() ?? '';
      _discountController.text = (widget.offer!.discountPercentage?.toString() ??
          widget.offer!.fixedPrice?.toString() ??
          '');
      _validUntil = widget.offer!.validUntil;
      _images = List.from(widget.offer!.images);
      _providerLogo = widget.offer!.serviceProviderLogo;
      _isPercentage = widget.offer!.discountPercentage != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _providerNameController.dispose();
    _originalPriceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    children: [
                      _buildImagePicker(),
                      SizedBox(height: 24),
                      _buildProviderSection(),
                      SizedBox(height: 24),
                      _buildOfferDetails(),
                      SizedBox(height: 24),
                      _buildPricingSection(),
                      SizedBox(height: 24),
                      _buildValiditySection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              widget.offer != null ? Icons.edit : Icons.local_offer,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.offer != null ? 'Edit Offer' : 'Add New Offer',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Create an attractive offer for your customers',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _isLoading ? null : _handleSubmit,
            icon: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            )
                : Icon(Icons.save),
            label: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return MultiImagePickerWidget(
      title: 'Offer Images',
      images: widget.offer?.images != null
          ? List<File>.from(widget.offer!.images.map((url) => File(url)))
          : _images,
      onPick: (files) {
        setState(() => _images = files);
      },
      maxImages: 5,
    );
  }

  Widget _buildProviderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Provider',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: ImagePickerWidget(
                title: '',
                image: widget.offer?.serviceProviderLogo != null
                    ? File(widget.offer!.serviceProviderLogo!)
                    : _providerLogoFile,
                onPick: (file) {
                  setState(() => _providerLogoFile = file);
                },
                isCircular: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _providerNameController,
                decoration: InputDecoration(
                  labelText: 'Provider Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value?.isEmpty == true ? 'Provider name is required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildOfferDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offer Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
          value?.isEmpty == true ? 'Title is required' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _detailsController,
          decoration: InputDecoration(
            labelText: 'Details',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          validator: (value) =>
          value?.isEmpty == true ? 'Details are required' : null,
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _originalPriceController,
                decoration: InputDecoration(
                  labelText: 'Original Price',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Original price is required';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _discountController,
                decoration: InputDecoration(
                  labelText:
                  _isPercentage ? 'Discount Percentage' : 'Fixed Price',
                  border: OutlineInputBorder(),
                  suffixText: _isPercentage ? '%' : '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'This field is required';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Invalid number';
                  }
                  if (_isPercentage && double.parse(value) > 100) {
                    return 'Max 100%';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        SwitchListTile(
          title: Text('Use percentage discount'),
          value: _isPercentage,
          onChanged: (value) => setState(() => _isPercentage = value),
        ),
      ],
    );
  }

  Widget _buildValiditySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Validity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        ListTile(
          title: Text(_validUntil == null
              ? 'No end date'
              : 'Valid until ${_validUntil.toString().substring(0, 10)}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: _pickDate,
                child: Text(_validUntil == null ? 'Set Date' : 'Change'),
              ),
              if (_validUntil != null)
                TextButton(
                  onPressed: () => setState(() => _validUntil = null),
                  child: Text('Remove'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _validUntil = date);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty && widget.offer?.images == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<OfferProvider>();

      final offer = OfferModel(
        id: widget.offer?.id,
        title: _titleController.text,
        details: _detailsController.text,
        serviceProviderName: _providerNameController.text,
        serviceProviderLogo: _providerLogoFile?.path ?? widget.offer?.serviceProviderLogo,
        images: _images.isNotEmpty
            ? _images.map((file) => file.path).toList()
            : widget.offer?.images ?? [],
        originalPrice: double.parse(_originalPriceController.text),
        discountPercentage:
        _isPercentage ? double.parse(_discountController.text) : null,
        fixedPrice:
        !_isPercentage ? double.parse(_discountController.text) : null,
        validUntil: _validUntil,
        createdBy: 'Ramy888',
        createdAt: widget.offer?.createdAt ?? DateTime.now(),
      );

      if (widget.offer != null) {
        await provider.updateOffer(offer);
      } else {
        await provider.createOffer(offer);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.offer != null ? 'Offer updated' : 'Offer created',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}