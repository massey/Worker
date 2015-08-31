/**
* A 2 dimensional vector with various operations
*/

class MASVector {
public:
	
	// Member variables
	double x;
	double y;

	// Constructors
	MASVector(double _x = 0, double _y = 0);

	double length(void);
	// Return the unit vector
	MASVector* unit();
	void rotate(double);

	// Operator overloads
    void operator=(MASVector);
    void operator-();
    void operator-(MASVector);
	MASVector operator+(MASVector);
	void operator*(double);

	// Static member functions
	double static dot(MASVector, MASVector);
	double static angle(MASVector, MASVector);
};


