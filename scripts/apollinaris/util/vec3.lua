vec3 = {}

function vec3.eq(vector1, vector2)
    return vector1[1] == vector2[1] and vector1[2] == vector2[2] and vector1[3] == vector2[3]
end

function vec3.add(vector, scalar_or_vector)
    if type(scalar_or_vector) == "table" then
        return {
            vector[1] + scalar_or_vector[1],
            vector[2] + scalar_or_vector[2],
            vector[3] + scalar_or_vector[3],
        }
    else
        return {
            vector[1] + scalar_or_vector,
            vector[2] + scalar_or_vector,
            vector[3] + scalar_or_vector
        }
    end
end

function vec3.sub(vector, scalar_or_vector)
    if type(scalar_or_vector) == "table" then
        return {
            vector[1] - scalar_or_vector[1],
            vector[2] - scalar_or_vector[2],
            vector[3] - scalar_or_vector[3],
        }
    else
        return {
            vector[1] - scalar_or_vector,
            vector[2] - scalar_or_vector,
            vector[3] - scalar_or_vector
        }
    end
end

function vec3.mul(vector, scalar_or_vector)
    if type(scalar_or_vector) == "table" then
        return {
            vector[1] * scalar_or_vector[1],
            vector[2] * scalar_or_vector[2],
            vector[3] * scalar_or_vector[3],
        }
    else
        return {
            vector[1] * scalar_or_vector,
            vector[2] * scalar_or_vector,
            vector[3] * scalar_or_vector
        }
    end
end
  
function vec3.div(vector, scalar)
    if scalar == 0 then return vector end
    return {
        vector[1] / scalar,
        vector[2] / scalar,
        vector[3] / scalar
    }
end

function vec3.mag(vector)
    return math.sqrt(vector[1] * vector[1] + vector[2] * vector[2] + vector[3]*vector[3])
end

function vec3.norm(vector)
    return vec3.div(vector, vec3.mag(vector))
end

function vec3.rotate_around_x(vector, angle)
    return {
        vector[1],
        vector[2]*math.cos(angle) - vector[3]*math.sin(angle),
        vector[2]*math.sin(angle) + vector[3]*math.cos(angle)
    }
end

function vec3.rotate_around_y(vector, angle)
    return {
        vector[1]*math.cos(angle) + vector[3]*math.sin(angle),
        vector[2],
        -vector[1]*math.sin(angle) + vector[3]*math.cos(angle)
    }
end

function vec3.rotate_around_z(vector, angle)
    return {
        vector[1]*math.cos(angle) - vector[2]*math.sin(angle),
        vector[1]*math.sin(angle) + vector[2]*math.cos(angle),
        vector[3]
    }
end

function vec3.polar(base, radius, polar, alpha)
    return {
        base[1] + radius* math.sin(polar) * math.cos(alpha),
        base[2] + radius * math.sin(polar) * math.sin(alpha),
        base[3] + radius * math.cos(polar)
    }
end