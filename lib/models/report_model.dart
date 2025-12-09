import 'package:flutter/material.dart';

class ReportModel
{
  final int? id;
  final String judul;
  final String deskripsi;
  final String foto;
  final double latitude;
  final double longitude;
  final int status;
  final String? officerNotes;
  final String? officerFoto;

    ReportModel({
    this.id,
    required this.judul,
    required this.deskripsi,
    required this.foto,
    required this.latitude,
    required this.longitude,
    this.status = 0,
    this.officerNotes,
    this.officerFoto,
  });

    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'foto': foto,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'officerNotes': officerNotes,
      'officerFoto': officerFoto,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String,
      foto: map['foto'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      status: map['status'] as int,
      officerNotes: map['officerNotes'] as String?,
      officerFoto: map['officerFoto'] as String?,
    );
  }

    ReportModel copyWith({
    int? id,
    String? judul,
    String? deskripsi,
    String? foto,
    double? latitude,
    double? longitude,
    int? status,
    String? officerNotes,
    String? officerFoto,
  }) {
    return ReportModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      foto: foto ?? this.foto,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      officerNotes: officerNotes ?? this.officerNotes,
      officerFoto: officerFoto ?? this.officerFoto,
    );
  }
}