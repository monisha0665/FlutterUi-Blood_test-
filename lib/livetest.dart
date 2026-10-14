import 'package:flutter/material.dart';

class LiveTest extends StatelessWidget {
  const LiveTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'Blood Requests',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: const [
          BloodCard(
            Group: 'O-',
            units: 3,
            hospital: 'Khulna City Medical College Hospital, KDA Ave..',
          ),
          SizedBox(height: 22),
          BloodCard(
            Group: 'O+',
            units: 2,
            hospital: 'Khulna City Medical College Hospital, KDA Ave..',
          ),
        ],
      ),
    );
  }
}

class BloodCard extends StatelessWidget {
  final String Group;
  final int units;
  final String hospital;

  const BloodCard({
    super.key,
    required this.Group,
    required this.units,
    required this.hospital,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 7,
              decoration: const BoxDecoration(
                color: Color(0xFFD94B69),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8ED),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'URGENT',
                            style: TextStyle(
                              color: Color(0xFFD94B69),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.water_drop,
                              color: Color(0xFFD94B69),
                              size: 21,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              '$units Units',
                              style: const TextStyle(
                                color: Color(0xFF263859),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      '$Group Blood Needed',
                      style: const TextStyle(
                        color: Color(0xFF263859),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 1),
                        Expanded(
                          child: Text(
                            hospital,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF20365D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
