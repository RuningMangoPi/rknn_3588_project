#ifndef INFER_HPP
#define INFER_HPP

#include "tensor.hpp"

namespace Object{

    class Infer {
    public:
        virtual bool     forward() = 0;
        virtual std::shared_ptr<MixMemory> get_workspace() = 0;
        virtual std::shared_ptr<Tensor>    input (int index = 0) = 0;
        virtual std::shared_ptr<Tensor>    output(int index = 0) = 0;
        virtual std::shared_ptr<Tensor>    tensor(const std::string& name) = 0;
        virtual std::string get_input_name (int index = 0) = 0;
        virtual std::string get_output_name(int index = 0) = 0;
        virtual bool is_output_name(const std::string& name) = 0;
        virtual bool is_input_name (const std::string& name) = 0;
        virtual int  num_output() = 0;
        virtual int  num_input() = 0;
        virtual void print() = 0;
        virtual void set_input (int index, std::shared_ptr<Tensor> tensor) = 0;
        virtual void set_output(int index, std::shared_ptr<Tensor> tensor) = 0;
    };
}; 

#endif // INFER_HPP