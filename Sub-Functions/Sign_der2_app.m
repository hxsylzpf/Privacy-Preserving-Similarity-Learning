function Sign_der2_Z = Sign_der2_app(Z,e)

Sign_der2_Z = (-3*e*Z)./(((Z.*Z)+e).^(5/2));

end

