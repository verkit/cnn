import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://lh3.googleusercontent.com/a/ALm5wu3wi37BpiIVk1iySbnKrA8YeqJeRKujW7rMPJWNdQ=s288-p-no',
              height: 100,
            ),
            SizedBox(height: 12),
            Text(
              'Made with Love By',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text('Verdy Bangkit Yudho Negoro'),
            Text('NIM.172410101081'),
            SizedBox(height: 12),
            Text('Sistem Informasi'),
            Text('Fakultas Ilmu Komputer'),
            Text('Universitas Jember'),
          ],
        ),
      ),
    );
  }
}
