#include "MASVector.h"
#include <math.h>

MASVector::MASVector(double _x, double _y)
{
	x = _x;
	y = _y;
}

double MASVector::length()
{
	return sqrt(pow(x, 2) + pow(y, 2));
}


MASVector* MASVector::unit()
{
	MASVector* unit = new MASVector;

	double length = this->length();

	unit->x = x / length;
	unit->y = y / length;

	return unit;
}

void MASVector::rotate(double angle)
{
    this->x = this->x * cos(angle) - this->y * sin(angle);
	this->y = this->x * sin(angle) + this->y * cos(angle);
}

void MASVector::operator=(MASVector vector)
{
    x = vector.x;
    y = vector.y;
}

void MASVector::operator-()
{
	x = -x;
	y = -y;
}

void MASVector::operator-(MASVector vector)
{
    x -= vector.x;
    y -= vector.y;
}

MASVector MASVector::operator+(MASVector vector)
{
    MASVector result;
    
    result.x += vector.x;
	result.y += vector.y;
    
    return result;
}

void MASVector::operator*(double m)
{
	x *= m;
	y *= m;
}

double MASVector::dot(MASVector v1, MASVector v2)
{
	return v1.x * v2.x + v1.y * v2.y;
}

double MASVector::angle(MASVector v1, MASVector v2)
{
	return acos(MASVector::dot(v1, v2) / (v1.length() * v2.length()));
}
