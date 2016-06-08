function Sign_Z = Sign_app(Z,e)

Sign_Z = Z./(((Z.*Z)+e).^(1/2));

end

