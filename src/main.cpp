#include <Buffers.hpp> 
#include <Program.hpp>
#include <Types.hpp>
#include <VertexArray.hpp>
#include <VertexLayout.hpp>
#include <Window.hpp> 
#include <filesystem> 
#include <vector> 

#include "glm/matrix.hpp"
#include "json_import.hpp"

static const std::vector<float> vertices = {
    // positions         // texture coords
    1.0f,  1.0f, 0.0f,   1.0f, 1.0f, // top right
    1.0f, -1.0f, 0.0f,   1.0f, 0.0f, // bottom right
    -1.0f, -1.0f, 0.0f,  0.0f, 0.0f, // bottom left
    -1.0f,  1.0f, 0.0f,  0.0f, 1.0f  // top left 
};

static const std::vector<etugl::u32> indices = { 
    0, 1, 3, // first triangle 
    1, 2, 3  // second triangle
}; 

int main (int argc, char** argv) {
    const fs::path path = fs::path(std::string(argv[argc-1])).parent_path();
    std::vector<PrimitiveInfo> primitives;
    std::vector<int> nodes; 
    std::vector<int> parent; 
    std::vector<std::vector<int>> children;

    formatJsonFileToVectors(
        path/"scene_small.json",
        primitives, nodes,
        parent, children 
    ); 

    etugl::Window window = etugl::WinPerspective({
        .m_Width = 800, 
        .m_Height = 800,
        .m_Title = "Hackmore", 
        .m_BGColor = 0x1E1E1EFF
    });
    etugl::Camera& camera = window.camera(); 

    etugl::VertexArray vao(
        vertices, indices, 
        etugl::VertexLayout() 
            .add<etugl::LayoutType::Float3>(0) 
            .add<etugl::LayoutType::Float2>(1) 
    ); 
 
    vao.bind(); 
    etugl::Program program(path/"vert.glsl", path/"frag.glsl"); 

    program.bind(); 

    size_t num_primitives = primitives.size();
    LOG_INFO("Setting up {} primitives from JSON", num_primitives);
    for (int i = 0; i < num_primitives; ++i) {
        const PrimitiveInfo& primitive = primitives[i]; 
        const etugl::mat4f inverse_matrix = glm::inverse(primitive.matrix);

        std::string base_name = "u_Primitives[" + std::to_string(i) + "]";
        program.set_float(base_name + ".type",      primitive.type);
        program.set_vec4f(base_name + ".color",     primitive.color);
        program.set_mat4f(base_name + ".model",     primitive.matrix, true);
        program.set_mat4f(base_name + ".inv_model", inverse_matrix, true); 
    } 

    program.set_vec2f("u_Resolution", 
        etugl::vec2f((float)camera.width(), (float)camera.height())
    );
    
    // Renderer loop 
    while (!window.is_closed()) {
        glClear(GL_COLOR_BUFFER_BIT);  
        window.update(); 

        program.bind();
        etugl::mat4f view = camera.view();
        etugl::mat4f projection = camera.projection();
        etugl::vec3f cam_pos = camera.position();

        program.set_vec3f("u_ViewPos", cam_pos); 
        program.set_mat4f("u_View", view);
        program.set_mat4f("u_InvView", glm::inverse(view));
        program.set_mat4f("u_Projection", projection); 

        vao.draw();

        window.swap();
        glfwPollEvents();
    }

    return 0;
}
