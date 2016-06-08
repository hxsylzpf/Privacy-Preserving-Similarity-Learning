function Sign_der_Z = Sign_der_app(Z,e)

Sign_der_Z = e./(((Z.*Z)+e).^(3/2));

end

