#include "CppBackend.hpp"
#include <qrandom.h>

CppBackend::CppBackend(QObject *parent) : QObject(parent), m_value(0) {}

void CppBackend::generateValue(int min, int max) {
  const int randNumber = QRandomGenerator::global()->bounded(min, max);
  setValue(randNumber);
}
