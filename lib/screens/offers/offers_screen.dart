import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/offer_model.dart';
import '../../providers/offers_provider.dart';
import 'add_offer_sheet.dart';


class OffersScreen extends StatefulWidget {
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Special Offers'),
          ),
          body: StreamBuilder<List<OfferModel>>(
            stream: provider.getOffers(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final offers = snapshot.data!;
              if (offers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No active offers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first offer by tapping the button below',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: offers.length,
                padding: EdgeInsets.all(16),
                itemBuilder: (context, index) => _buildOfferCard(
                  context,
                  offers[index],
                  provider,
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddOfferSheet(context),
            icon: Icon(Icons.add),
            label: Text('Add Offer'),
          ),
        );
      },
    );
  }

  Widget _buildOfferCard(
      BuildContext context,
      OfferModel offer,
      OfferProvider provider,
      ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer.images.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                viewportFraction: 1,
                enableInfiniteScroll: offer.images.length > 1,
                autoPlay: offer.images.length > 1,
              ),
              items: offer.images.map((imageUrl) {
                return Builder(
                  builder: (context) {
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  },
                );
              }).toList(),
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (offer.serviceProviderLogo != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: offer.serviceProviderLogo!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.serviceProviderName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            timeago.format(offer.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) =>
                          _handleAction(action, offer, provider),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: offer.isActive ? 'deactivate' : 'activate',
                          child: ListTile(
                            leading: Icon(
                              offer.isActive
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: offer.isActive ? Colors.red : Colors.green,
                            ),
                            title: Text(
                              offer.isActive ? 'Deactivate' : 'Activate',
                              style: TextStyle(
                                color: offer.isActive ? Colors.red : Colors.green,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  offer.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8),
                Text(
                  offer.details,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        offer.displayPrice,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (offer.originalPrice != null) ...[
                      SizedBox(width: 8),
                      Text(
                        '\$${offer.originalPrice!.toStringAsFixed(2)}',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Save ${offer.savings}',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                if (offer.validUntil != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Valid until ${offer.validUntil!.toString().substring(0, 10)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(
      String action,
      OfferModel offer,
      OfferProvider provider,
      ) async {
    switch (action) {
      case 'deactivate':
      case 'activate':
        final newStatus = action == 'activate';
        try {
          await provider.toggleOfferStatus(offer.id!, newStatus);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus ? 'Offer activated' : 'Offer deactivated',
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;

      case 'edit':
        _showAddOfferSheet(context, offer: offer);
        break;
    }
  }

  void _showAddOfferSheet(BuildContext context, {OfferModel? offer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddOfferSheet(offer: offer),
    );
  }
}