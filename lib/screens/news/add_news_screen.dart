import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/news_model.dart';
import '../../providers/news_provider.dart';
import '../../widgets/projects/multi_image_picker.dart';

class AddNewsScreen extends StatefulWidget {
  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  NewsModel _news = NewsModel.empty();
  List<File> _images = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add News'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _handleSubmit,
            icon: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
                : Icon(Icons.save, color: Colors.white),
            label: Text(
              'Publish',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildImagePicker(),
            SizedBox(height: 24),
            _buildTitleSection(),
            SizedBox(height: 24),
            _buildBodySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        MultiImagePickerWidget(
          images: _images,
          onPick: (images) {
            setState(() => _images = images);
          },
          maxImages: 5,
          title: 'Select News Images',
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Title (English)',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
          value?.isEmpty == true ? 'Title is required' : null,
          onSaved: (value) => _news = _news.copyWith(title: value),
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Title (Arabic)',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
          validator: (value) =>
          value?.isEmpty == true ? 'Arabic title is required' : null,
          onSaved: (value) => _news = _news.copyWith(titleAr: value),
        ),
      ],
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Content (English)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          validator: (value) =>
          value?.isEmpty == true ? 'Content is required' : null,
          onSaved: (value) => _news = _news.copyWith(body: value),
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Content (Arabic)',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          textDirection: TextDirection.rtl,
          validator: (value) =>
          value?.isEmpty == true ? 'Arabic content is required' : null,
          onSaved: (value) => _news = _news.copyWith(bodyAr: value),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      _formKey.currentState!.save();

      final newsProvider = context.read<NewsProvider>();

      await newsProvider.addNews(
        _news.copyWith(
          createdAt: DateTime.now(),
          createdBy: 'Ramy888',
        ),
        _images,
      );

      if (newsProvider.status == NewsOperationStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('News published successfully')),
        );
        Navigator.pop(context);
      } else if (newsProvider.status == NewsOperationStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${newsProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}