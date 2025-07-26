#include <QObject>
#include <QtQml>

class CppBackend : public QObject {
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(int value READ value WRITE setValue NOTIFY valueChanged)

public:
  explicit CppBackend(QObject *parent = nullptr);
  Q_INVOKABLE void generateValue(int min, int max);

  int value() const { return m_value; }
  void setValue(int val) {
    if (val != m_value) {
      m_value = val;
      emit valueChanged(m_value);
    }
  }

signals:
  void valueChanged(int number);

private:
  int m_value;
};
